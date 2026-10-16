#!/bin/bash
# Sunshine do_cmd/undo_cmd: switch the display mode via kscreen-doctor.
#
# Usage:
#   sunshine-switch-mode.sh            -> fallback 1920x1080@60 (used as undo_cmd)
#   sunshine-switch-mode.sh W H [FPS]  -> best mode at WxH with highest
#                                         refresh <= FPS (used as do_cmd;
#                                         W/H come from SUNSHINE_CLIENT_*)
#
# If no matching mode exists the script silently keeps the current mode, so
# the stream always connects.

set -uo pipefail

CONNECTOR="DP-1"
FALLBACK_W=1920
FALLBACK_H=1080
FALLBACK_FPS=60

if [ $# -ge 2 ]; then
    W="$1"; H="$2"; FPS="${3:-60}"
    TAG="do"
else
    W="$FALLBACK_W"; H="$FALLBACK_H"; FPS="$FALLBACK_FPS"
    TAG="undo"
fi

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

# Best available mode: exact WxH, highest refresh <= requested FPS
MODE=$(kscreen-doctor -o 2>/dev/null | awk -v w="$W" -v h="$H" -v fps="$FPS" '
  /Output:/ {out=1}
  out && /Modes:/ {
    for (i = 1; i <= NF; i++) {
      if ($i ~ /^[0-9]+:[0-9]+x[0-9]+@/) {
        split($i, a, ":")
        split(a[2], b, "x")
        split(b[2], c, "@")
        mw = b[1] + 0; mh = c[1] + 0; mfps = c[2] + 0
        if (mw == w && mh == h && mfps <= fps + 0.5 && mfps > best) {
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

if [ -z "${MODEID:-}" ]; then
    echo "sunshine-$TAG: no mode ${W}x${H} available, keeping current mode" >&2
    exit 0
fi

echo "sunshine-$TAG: switching ${CONNECTOR} to mode ${MODEID} (${W}x${H}@${BEST})" >&2
kscreen-doctor "output.${CONNECTOR}.mode.${MODEID}" >/dev/null 2>&1
