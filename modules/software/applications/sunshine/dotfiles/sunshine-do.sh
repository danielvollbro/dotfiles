#!/bin/bash
# Sunshine "Do" command: switch the display to the connecting client's
# resolution before the session starts. Moonlight/Sunshine exports
# SUNSHINE_CLIENT_WIDTH / _HEIGHT / _FPS for the session.
#
# Falls back silently (stays in current mode) if the requested mode does not
# exist — the stream still connects, just with the current resolution.

set -uo pipefail

CONNECTOR="DP-1"
W="${SUNSHINE_CLIENT_WIDTH:-}"
H="${SUNSHINE_CLIENT_HEIGHT:-}"
FPS="${SUNSHINE_CLIENT_FPS:-60}"

[ -z "$W" ] || [ -z "$H" ] && exit 0

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

# Pick the best available mode: exact WxH with highest refresh <= requested FPS
MODE=$(kscreen-doctor -o 2>/dev/null | awk -v w="$W" -v h="$H" '
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
' fps="$FPS" -)
MODEID="${MODE%% *}"
BEST="${MODE##* }"

[ -z "${MODEID:-}" ] && {
  echo "sunshine-do: no mode ${W}x${H} available, keeping current mode" >&2
  exit 0
}

echo "sunshine-do: switching ${CONNECTOR} to mode ${MODEID} (${W}x${H}@${BEST})" >&2
kscreen-doctor "output.${CONNECTOR}.mode.${MODEID}" >/dev/null 2>&1
