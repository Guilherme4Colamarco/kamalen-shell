#!/usr/bin/env python3
import subprocess
import re
import sys

def write_flush(s):
    sys.stdout.write(s + "\n")
    sys.stdout.flush()

proc = subprocess.Popen(
    ["dbus-monitor", "interface='org.freedesktop.Notifications',member='Notify'"],
    stdout=subprocess.PIPE,
    stderr=subprocess.DEVNULL,
    text=True
)

state = 0
strings = []
str_re = re.compile(r'^\s*string\s*"(.*)"\s*$')

for line in proc.stdout:
    line_strip = line.strip()
    if "member=Notify" in line_strip:
        state = 1
        strings = []
        continue

    if state == 1:
        if line_strip.startswith("method call") or line_strip.startswith("signal") or line_strip.startswith("method return") or line_strip.startswith("error"):
            state = 0
            continue

        m = str_re.match(line)
        if m:
            val = m.group(1)
            val = val.replace('\\"', '"').replace('\\\\', '\\')
            strings.append(val)
            if len(strings) >= 4:
                appname = strings[0].replace("\t", " ").replace("\n", " ").strip()
                summary = strings[2].replace("\t", " ").replace("\n", " ").strip()
                body = strings[3].replace("\t", " ").replace("\n", " ").strip()
                write_flush(f"{appname}\t{summary}\t{body}")
                state = 0
