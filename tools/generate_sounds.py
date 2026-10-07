#!/usr/bin/env python3
"""Generate small original WAV assets for PuzzleMix.

No external audio files are downloaded. Every sound is synthesized here so the
game can ship with lightweight, original effects and a soft background loop.
"""

from __future__ import annotations

import math
import os
import random
import struct
import wave

RATE = 22050
OUT = os.path.join("assets", "sounds")
os.makedirs(OUT, exist_ok=True)


def clamp(v: float) -> float:
    return max(-1.0, min(1.0, v))


def write_wav(name: str, samples: list[float]) -> None:
    path = os.path.join(OUT, name)
    with wave.open(path, "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(RATE)
        frames = bytearray()
        for sample in samples:
            frames.extend(struct.pack("<h", int(clamp(sample) * 32767)))
        wav.writeframes(frames)


def env(t: float, duration: float, attack: float = 0.02, release: float = 0.08) -> float:
    a = min(1.0, t / max(attack, 1e-6))
    r = min(1.0, (duration - t) / max(release, 1e-6))
    return max(0.0, min(a, r, 1.0))


def tone(freq: float, duration: float, volume: float = 0.5, attack: float = 0.01, release: float = 0.08) -> list[float]:
    total = int(RATE * duration)
    out = []
    for i in range(total):
        t = i / RATE
        e = env(t, duration, attack, release)
        fundamental = math.sin(2 * math.pi * freq * t)
        harmonic = 0.22 * math.sin(2 * math.pi * freq * 2 * t)
        out.append((fundamental + harmonic) * volume * e)
    return out


def mix(parts: list[tuple[list[float], int]], gain: float = 1.0) -> list[float]:
    length = max((offset + len(samples) for samples, offset in parts), default=0)
    out = [0.0] * length
    for samples, offset in parts:
        for i, sample in enumerate(samples):
            out[offset + i] += sample
    peak = max((abs(v) for v in out), default=1.0)
    scale = gain / peak if peak > gain else 1.0
    return [v * scale for v in out]


def seconds(value: float) -> int:
    return int(value * RATE)


# Soft tactile tap.
tap = mix([
    (tone(880, 0.075, 0.35, 0.002, 0.055), 0),
    (tone(1320, 0.05, 0.18, 0.001, 0.04), 0),
], 0.42)
write_wav("tap.wav", tap)

# Liquid pour: filtered-looking noise + descending/ascending glass tone.
random.seed(42)
duration = 0.58
pour = []
for i in range(int(RATE * duration)):
    t = i / RATE
    e = env(t, duration, 0.04, 0.12)
    freq = 520 + 120 * math.sin(math.pi * t / duration)
    glass = math.sin(2 * math.pi * freq * t) * 0.12
    noise = (random.random() * 2 - 1) * 0.10
    bubble = math.sin(2 * math.pi * (90 + 40 * math.sin(t * 18)) * t) * 0.06
    pour.append((glass + noise + bubble) * e)
write_wav("pour.wav", pour)

# Matching a completed vial.
match = mix([
    (tone(659.25, 0.24, 0.40), 0),
    (tone(783.99, 0.28, 0.34), seconds(0.07)),
    (tone(987.77, 0.34, 0.30), seconds(0.14)),
], 0.62)
write_wav("match.wav", match)

# Friendly invalid-move cue, low and short rather than harsh.
error_sound = mix([
    (tone(210, 0.16, 0.26, 0.004, 0.08), 0),
    (tone(165, 0.18, 0.22, 0.004, 0.10), seconds(0.07)),
], 0.35)
write_wav("error.wav", error_sound)

# Arrow escape whoosh.
random.seed(7)
duration = 0.30
whoosh = []
for i in range(int(RATE * duration)):
    t = i / RATE
    e = env(t, duration, 0.015, 0.12)
    sweep = math.sin(2 * math.pi * (380 + 1200 * t) * t) * 0.12
    noise = (random.random() * 2 - 1) * (0.18 * (1 - t / duration))
    whoosh.append((sweep + noise) * e)
write_wav("whoosh.wav", whoosh)

# Color Crew pop.
pop = mix([
    (tone(360, 0.09, 0.30, 0.002, 0.06), 0),
    (tone(720, 0.14, 0.24, 0.002, 0.10), seconds(0.025)),
], 0.46)
write_wav("pop.wav", pop)

# Celebration chord/arpeggio.
success = mix([
    (tone(523.25, 0.55, 0.26, 0.008, 0.24), 0),
    (tone(659.25, 0.55, 0.27, 0.008, 0.24), seconds(0.13)),
    (tone(783.99, 0.70, 0.28, 0.008, 0.30), seconds(0.26)),
    (tone(1046.50, 0.88, 0.30, 0.008, 0.38), seconds(0.42)),
    (tone(1318.51, 0.62, 0.17, 0.008, 0.30), seconds(0.64)),
], 0.72)
write_wav("success.wav", success)

# Calm, bright 8-second background loop with a gentle pulse.
duration = 8.0
total = int(RATE * duration)
notes = [261.63, 329.63, 392.00, 493.88]
background = [0.0] * total
for i in range(total):
    t = i / RATE
    # Keep the loop edges at zero to avoid a click.
    edge = min(1.0, t / 0.10, (duration - t) / 0.10)
    pulse = 0.72 + 0.28 * math.sin(2 * math.pi * 0.5 * t) ** 2
    chord = (
        math.sin(2 * math.pi * notes[0] * t) * 0.040
        + math.sin(2 * math.pi * notes[1] * t) * 0.032
        + math.sin(2 * math.pi * notes[2] * t) * 0.028
    )
    bell_index = int(t // 2) % len(notes)
    phase = t % 2.0
    bell_env = math.exp(-2.7 * phase)
    bell = math.sin(2 * math.pi * notes[bell_index] * 2 * phase) * 0.030 * bell_env
    background[i] = (chord * pulse + bell) * edge
write_wav("background.wav", background)

print("Generated PuzzleMix sound pack in assets/sounds/")
