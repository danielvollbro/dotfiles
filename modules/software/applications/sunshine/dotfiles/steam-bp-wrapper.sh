#!/usr/bin/env bash
# Steam Big Picture launcher for the Sunshine "Steam Big Picture" app.
#
# Why this exists: the NixOS Sunshine service environment leaks Nix-specific
# variables into spawned apps (LD_LIBRARY_PATH pointing at the vulkan loader,
# QT_PLUGIN_PATH/QML2_IMPORT_PATH, XCURSOR_PATH, ...). Steam's pressure-vessel
# sandbox (bwrap) aborts on that environment:
#   bwrap: Unexpected capabilities but not setuid, old file caps config?
# Steam then dies silently and the app never appears. Manual "steam" from a
# normal shell works because the session env there is tolerated by bwrap.
#
# Fix: exec Steam in a clean environment, keeping only the session-display
# variables needed to reach the KDE/Wayland session (X11 via Xwayland :0).
export DISPLAY="${DISPLAY:-:0}"
[ -z "$XAUTHORITY" ] && export XAUTHORITY=$(ls -t /run/user/$(id -u)/xauth_* 2>/dev/null | head -1)
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"

exec env -i \
  HOME=/home/daniel USER=daniel LOGNAME=daniel \
  PATH=/run/current-system/sw/bin:/home/daniel/.local/bin \
  DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" \
  XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
  steam steam://open/bigpicture
