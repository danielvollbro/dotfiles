#!/usr/bin/env bash
# Sunshine global_prep_cmd: switch the display mode via kscreen-doctor.
#
# Sunshine runs this without a shell and without argument expansion, so the
# client resolution is read from the environment: when Sunshine launches a
# session it sets SUNSHINE_CLIENT_WIDTH / _HEIGHT / _FPS (do), on disconnect
# they are absent (undo) and the script falls back to 1920x1080@60.
#
# If no matching mode exists the script silently keeps the current mode, so
# the stream always connects.

set -uo pipefail

CONNECTOR="DP-1"
FALLBACK_W=1920
FALLBACK_H=1080
FALLBACK_FPS=60

if [ -n "${SUNSHINE_CLIENT_WIDTH:-}" ] && [ -n "${SUNSHINE_CLIENT_HEIGHT:-}" ]; then
    W="$SUNSHINE_CLIENT_WIDTH"; H="$SUNSHINE_CLIENT_HEIGHT"
    FPS="${SUNSHINE_CLIENT_FPS:-$FALLBACK_FPS}"
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
