import os
import sys

if len(sys.argv) != 2:
    print("Usage: python3 move.py [dir_name]")
    exit(1)

dir = str(sys.argv[1])

full_list = os.listdir(str(dir))

plain_list = []
skin_tones = []

for item in full_list:
    if "1f3fb" in item or "1f3fc" in item or "1f3fd" in item or "1f3fe" in item or "1f3ff" in item:
        skin_tones.append(item)
    else:
        plain_list.append(item)

os.chdir(str(dir))
os.mkdir("plain")
os.mkdir("skin_tones")
for p in plain_list:
    os.rename(p, str("plain/" + p))

for s in skin_tones:
    os.rename(s, str("skin_tones/" + s))

print("Done")
