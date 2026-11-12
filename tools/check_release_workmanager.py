import struct,zipfile,sys
def inspect(data):
    def u32(o):return struct.unpack_from('<I',data,o)[0]
    def var(o):
        value=shift=0
        while True:
            b=data[o];o+=1;value|=(b&127)<<shift
            if b<128:return value,o
            shift+=7
    n,off=struct.unpack_from('<II',data,56);strings=[]
    for i in range(n):
        _,pos=var(u32(off+i*4));strings.append(data[pos:data.index(b'\0',pos)].decode('utf-8','replace'))
    n,off=struct.unpack_from('<II',data,64);types=[strings[u32(off+i*4)] for i in range(n)]
    proto=u32(76);methods=u32(92);n,off=struct.unpack_from('<II',data,96)
    result={}
    for i in range(n):
        pos=off+i*32;name=types[u32(pos)]
        if name not in ['Landroidx/work/impl/WorkDatabase_Impl;','Landroidx/work/OverwritingInputMerger;','Landroidx/work/ArrayCreatingInputMerger;']:continue
        p=u32(pos+24);counts=[];ctors=[]
        if not p:result[name]=ctors;continue
        for _ in range(4):count,p=var(p);counts.append(count)
        for _ in range(counts[0]+counts[1]):_,p=var(p);_,p=var(p)
        for count in counts[2:]:
            idx=0
            for _ in range(count):
                delta,p=var(p);idx+=delta;flags,p=var(p);code,p=var(p)
                _,pi,ni=struct.unpack_from('<HHI',data,methods+idx*8)
                if strings[ni]=='<init>':
                    po=u32(proto+pi*12+8)
                    params=[] if not po else [types[struct.unpack_from('<H',data,po+4+j*2)[0]] for j in range(u32(po))]
                    ctors.append({'params':params,'public':bool(flags&1),'code':bool(code)})
        result[name]=ctors
    return result
def check(apk):
    found={}
    with zipfile.ZipFile(apk) as z:
        for name in z.namelist():
            if name.startswith('classes') and name.endswith('.dex'):found.update(inspect(z.read(name)))
    return found
if __name__=='__main__':
    found=check(sys.argv[1])
    if True:
        for target in ['Landroidx/work/impl/WorkDatabase_Impl;','Landroidx/work/OverwritingInputMerger;','Landroidx/work/ArrayCreatingInputMerger;']:
            if not any(c['public'] and c['code'] and not c['params'] for c in found.get(target,[])):
                raise SystemExit('Missing reflection constructor: '+target)

    print('PASS: WorkManager/Room reflection constructors preserved')
