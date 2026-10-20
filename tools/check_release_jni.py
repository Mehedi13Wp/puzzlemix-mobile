"""Check the actual minified DEX method that preferences calls through JNI."""
from pathlib import Path
import struct
import sys
import zipfile

CLASS = "Lio/flutter/plugins/sharedpreferences/SharedPreferencesApiRegistrar;"
PARAMETERS = ["Ljava/lang/String;", "Ljava/util/List;", "Lkotlin/coroutines/Continuation;"]


def check_dex(data):
    def u32(offset):
        return struct.unpack_from("<I", data, offset)[0]

    def varint(offset):
        value = shift = 0
        while True:
            byte = data[offset]
            offset += 1
            value |= (byte & 127) << shift
            if byte < 128:
                return value, offset
            shift += 7

    string_count, string_offset = struct.unpack_from("<II", data, 56)
    strings = []
    for index in range(string_count):
        _, offset = varint(u32(string_offset + index * 4))
        strings.append(data[offset:data.index(b"\0", offset)].decode("utf-8", errors="replace"))
    type_count, type_offset = struct.unpack_from("<II", data, 64)
    types = [strings[u32(type_offset + index * 4)] for index in range(type_count)]
    proto_offset = u32(76)
    method_offset = u32(92)
    class_count, class_offset = struct.unpack_from("<II", data, 96)
    for index in range(class_count):
        offset = class_offset + index * 32
        if types[u32(offset)] != CLASS:
            continue
        offset = u32(offset + 24)
        if not offset:
            return False
        counts = []
        for _ in range(4):
            count, offset = varint(offset)
            counts.append(count)
        for _ in range(counts[0] + counts[1]):
            _, offset = varint(offset)
            _, offset = varint(offset)
        for method_count in counts[2:]:
            method_index = 0
            for _ in range(method_count):
                delta, offset = varint(offset)
                method_index += delta
                _, offset = varint(offset)
                code_offset, offset = varint(offset)
                _, proto_index, name_index = struct.unpack_from("<HHI", data, method_offset + method_index * 8)
                if strings[name_index] != "getAll":
                    continue
                proto = proto_offset + proto_index * 12
                params_offset = u32(proto + 8)
                params = [] if not params_offset else [
                    types[struct.unpack_from("<H", data, params_offset + 4 + p * 2)[0]]
                    for p in range(u32(params_offset))
                ]
                if params == PARAMETERS and types[u32(proto + 4)] == "Ljava/lang/Object;" and code_offset:
                    return True
    return False


def main():
    apk = Path(sys.argv[1])
    with zipfile.ZipFile(apk) as archive:
        valid = any(check_dex(archive.read(name)) for name in archive.namelist()
                    if name.startswith("classes") and name.endswith(".dex"))
    if not valid:
        raise SystemExit("FAIL: minified APK is missing the preferences JNI getAll(String, List, Continuation) method")
    print(f"PASS: preferences JNI signature preserved in {apk.name}")


if __name__ == "__main__":
    main()
