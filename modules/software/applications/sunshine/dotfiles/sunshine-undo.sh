#!/bin/bash
# Sunshine "Undo" command: restore the display to the fallback resolution
# (1920x1080@60) when the client disconnects. Guarantees a working mode even
# if the "Do" script switched to something the next client can't use.

set -uo pipefail

CONNECTOR="DP-1"
FALLBACK_W="1920"
FALLBACK_H="1080"
FALLBACK_FPS="60"

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

MODE=$(kscreen-doctor -o 2>/dev/null | awk -v w="$FALLBACK_W" -v h="$FALLBACK_H" -v f="$FALLBACK_FPS" '
  /Output:/ {out=1}
  out && /Modes:/ {
    for (i = 1; i <= NF; i++) {
      if ($i ~ /^[0-9]+:[0-9]+x[0-9]+@/) {
        split($i, a, ":")
        split(a[2], b, "x")
        split(b[2], c, "@")
        mfps = c[2] + 0
        if (b[1] + 0 == w && c[1] + 0 == h && mfps <= f + 0.5 && mfps > best) {
          best = mfps; modeid = a[1]
        }
      }
    }
    exit
  }
  END { print modeid, best }
' -)
MODEID="${MODE%% *}"
BEST="${MODE##* }"

[ -z "${MODEID:-}" ] && { echo "sunshine-undo: fallback mode not found" >&2; exit 0; }

echo "sunshine-undo: restoring ${CONNECTOR} to ${FALLBACK_W}x${FALLBACK_H}@${BEST}" >&2
kscreen-doctor "output.${CONNECTOR}.mode.${MODEID}" >/dev/null 2>&1
