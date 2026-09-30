#!/usr/bin/env bash
# NixOS bootstrap installer for hosts in this flake.
#
# Run from a NixOS installer ISO (or any Linux with nix + internet):
#   sudo nix --experimental-features "nix-command flakes" run github:danielvollbro/dotfiles#laptop-install
#
# The script:
#   1. clones this repo (or reuses an existing checkout)
#   2. wipes and partitions the target disk with disko
#   3. fetches the master age key from Vaultwarden (laptop only)
#   4. runs nixos-install with the host's flake configuration
#
# WARNING: step 2 DESTROYS everything on the target disk. You will be asked
# to confirm before that happens.

set -euo pipefail

HOST="${1:-}"
REPO_URL="https://github.com/danielvollbro/dotfiles.git"
CHECKOUT="${DOTFILES_DIR:-/root/dotfiles}"
KEY_DST="/mnt/var/lib/sops/age/master.key"
# Vaultwarden secure note holding the master age key in its notes field.
BW_ITEM_NAME="${BW_ITEM_NAME:-master-age-key}"
BW_URL="${BW_URL:-https://vaultwarden.home.vollbro.se}"

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

# --- 3. master age key (from Vaultwarden) -----------------------------------
if [ "$NEEDS_MASTER_KEY" -eq 1 ]; then
  if [ -f "$KEY_DST" ]; then
    info "master key already in place at $KEY_DST"
  else
    # Manual fallback: point BW_KEY_FILE at a local copy of the key.
    KEY_SRC=""
    if [ -n "${BW_KEY_FILE:-}" ] && [ -f "$BW_KEY_FILE" ]; then
      KEY_SRC="$BW_KEY_FILE"
      info "using key from BW_KEY_FILE=$BW_KEY_FILE"
    else
      command -v bw >/dev/null || die "bitwarden CLI not found in PATH"
      command -v jq >/dev/null || die "jq not found in PATH"
      info "fetching master age key from Vaultwarden ($BW_URL)"
      read -rsp "Vaultwarden master password: " BW_PW
      echo

      bw config server "$BW_URL" >/dev/null
      # --passwordenv keeps the password out of argv/process listing;
      # the session key only exists in this shell, notes decrypt locally.
      BW_SESSION="$(BW_PASSWORD="$BW_PW" bw unlock --passwordenv BW_PASSWORD --raw)" \
        || { unset BW_PW; die "bw unlock failed (wrong password or unreachable Vaultwarden?)"; }
      unset BW_PW

      bw get notes "$BW_ITEM_NAME" --session "$BW_SESSION" > "$KEY_SRC" \
        || { unset BW_SESSION; rm -f "$KEY_SRC"; die "could not read notes of item '$BW_ITEM_NAME'"; }
      unset BW_SESSION
      chmod 600 "$KEY_SRC"
      [ -s "$KEY_SRC" ] || { rm -f "$KEY_SRC"; die "item '$BW_ITEM_NAME' has an empty notes field"; }
    fi

    info "placing master key at $KEY_DST"
    mkdir -p "$(dirname "$KEY_DST")"
    cp "$KEY_SRC" "$KEY_DST"
    chmod 700 "$(dirname "$KEY_DST")"
    chmod 600 "$KEY_DST"
    case "$KEY_SRC" in /tmp/*) rm -f "$KEY_SRC";; esac
  fi
fi

# --- 4. install --------------------------------------------------------------
info "running nixos-install for $HOST"
nixos-install --flake ".#$HOST"

info "done. Reboot with:  systemctl reboot"
