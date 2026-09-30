#!/usr/bin/env bash
# NixOS bootstrap installer for hosts in this flake.
#
# Run from a NixOS installer ISO (or any Linux with nix + internet):
#   sudo nix --experimental-features "nix-command flakes" run github:danielvollbro/dotfiles#laptop-install
#
# The script:
#   1. clones this repo (or reuses an existing checkout)
#   2. wipes and partitions the target disk with disko
#   3. places the master age key (for hosts that decrypt with age.keyFile)
#   4. runs nixos-install with the host's flake configuration
#
# WARNING: step 2 DESTROYS everything on the target disk. You will be asked
# to confirm before that happens.

set -euo pipefail

HOST="${1:-}"
REPO_URL="https://github.com/danielvollbro/dotfiles.git"
CHECKOUT="${DOTFILES_DIR:-/root/dotfiles}"
KEY_NAME="master.key"
KEY_DST="/mnt/var/lib/sops/age/${KEY_NAME}"

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }

[ "$(id -u)" -eq 0 ] || die "must run as root (sudo)"
[ -n "$HOST" ] || die "usage: $0 <host>   (e.g. $0 laptop)"

# --- host -> config mapping ------------------------------------------------
case "$HOST" in
  laptop)
    DISKO_FILE="hosts/laptop/disko.nix"
    NEEDS_MASTER_KEY=1
    ;;
  gaming-pc)
    DISKO_FILE="hosts/gaming-pc/disko.nix"
    NEEDS_MASTER_KEY=0
    ;;
  *) die "unknown host '$HOST' (known: laptop, gaming-pc)" ;;
esac

# --- 1. checkout ------------------------------------------------------------
if [ -d "$CHECKOUT/.git" ]; then
  info "using existing checkout at $CHECKOUT"
  git -C "$CHECKOUT" pull --ff-only || info "pull failed, continuing with local state"
else
  info "cloning $REPO_URL to $CHECKOUT"
  git clone "$REPO_URL" "$CHECKOUT"
fi
cd "$CHECKOUT"

# --- 2. disko ---------------------------------------------------------------
echo
echo "============================================================"
echo "  WARNING: about to DESTROY ALL DATA on the target disk"
echo "  host:    $HOST"
echo "  disko:   $DISKO_FILE"
echo "============================================================"
read -r -p "Type 'destroy' to continue: " ANSWER
[ "$ANSWER" = "destroy" ] || die "aborted"

info "running disko (partition + format + mount)"
nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest -- --mode destroy,format,mount "$DISKO_FILE"

# --- 3. master age key -------------------------------------------------------
if [ "$NEEDS_MASTER_KEY" -eq 1 ]; then
  find_master_key() {
    # 1) already mounted somewhere obvious?
    for p in "$CHECKOUT/master-age.key" /mnt/master-age.key /run/media/*/master-age.key; do
      [ -f "$p" ] && { echo "$p"; return; }
    done
    # 2) try to unmount the Ventoy data partition and mount it read-only
    local dev
    dev="$(lsblk -rno NAME,TRAN | awk '$2=="usb"{print "/dev/"$1; exit}')"
    if [ -n "${dev:-}" ]; then
      local part
      part="$(lsblk -rno NAME,TYPE "${dev}" | awk '$2=="part"{print "/dev/"$1; exit}')"
      if [ -n "${part:-}" ]; then
        umount -R /run/miso/bootmnt 2>/dev/null || true
        umount "${part}" 2>/dev/null || true
        mkdir -p /tmp/usbkey
        if mount -o ro "${part}" /tmp/usbkey 2>/dev/null; then
          for p in /tmp/usbkey/master-age.key /tmp/usbkey/master.key; do
            [ -f "$p" ] && { echo "$p"; return; }
          done
        fi
      fi
    fi
    echo ""
  }

  if [ -f "$KEY_DST" ]; then
    info "master key already in place at $KEY_DST"
  else
    KEY_SRC="$(find_master_key)"
    if [ -z "$KEY_SRC" ]; then
      read -r -p "Path to master-age.key on this machine: " KEY_SRC
      [ -f "$KEY_SRC" ] || die "no file at $KEY_SRC"
    fi
    info "placing master key at $KEY_DST"
    mkdir -p "$(dirname "$KEY_DST")"
    cp "$KEY_SRC" "$KEY_DST"
    chmod 700 "$(dirname "$KEY_DST")"
    chmod 600 "$KEY_DST"
    # best effort: undo temporary mounts
    umount /tmp/usbkey 2>/dev/null || true
  fi
fi

# --- 4. install --------------------------------------------------------------
info "running nixos-install for $HOST"
nixos-install --flake ".#$HOST"

info "done. Reboot with:  systemctl reboot"
