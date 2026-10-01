#!/usr/bin/env bash
# NixOS bootstrap installer for hosts in this flake.
#
# Run from a NixOS installer ISO (or any Linux with nix + internet):
#   sudo nix --experimental-features "nix-command flakes" run github:danielvollbro/dotfiles#laptop-install
#
# The script:
#   1. clones this repo (or reuses an existing checkout)
#   2. fetches the master age key from Vaultwarden (laptop only) — BEFORE
#      touching the disk, so a failed fetch aborts safely
#   3. wipes and partitions the target disk with disko
#   4. places the master key onto the new install
#   5. runs nixos-install with the host's flake configuration
#
# WARNING: step 3 DESTROYS everything on the target disk. You will be asked
# to confirm before that happens.

set -euo pipefail

# Enable flakes/nix-command for every nix invocation in this script,
# including ones that don't take --experimental-features directly (like
# nixos-install). The installer ISO's default nix.conf does NOT have these
# enabled, and nixos-install is a separate process that doesn't inherit
# flags passed to the outer `nix run` that launched this script.
export NIX_CONFIG="experimental-features = nix-command flakes"

# Explain *what* failed and *what step* we were on when set -e kills the
# script — without this, a typo'd LUKS passphrase (disko asks twice, exits
# non-zero on mismatch) just ends the script with zero explanation of what
# happened or what to do next.
CURRENT_STEP="startup"
on_err() {
  echo >&2
  echo "ERROR: script stopped during: $CURRENT_STEP" >&2
  echo "(likely cause: wrong password/passphrase re-typed, disko/install command failed, or network drop — scroll up for the actual error)" >&2
  echo "Just re-run the same command to retry from the top." >&2
}
trap on_err ERR

HOST="${1:-}"
REPO_URL="https://github.com/danielvollbro/dotfiles.git"
CHECKOUT="${DOTFILES_DIR:-/root/dotfiles}"
KEY_DST="/mnt/var/lib/sops/age/master.key"
# Vaultwarden secure note holding the master age key in its notes field.
BW_ITEM_NAME="${BW_ITEM_NAME:-master-age-key}"
BW_URL="${BW_URL:-https://vault.vollbro.se}"

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
CURRENT_STEP="cloning/updating the dotfiles checkout"
if [ -d "$CHECKOUT/.git" ]; then
  info "using existing checkout at $CHECKOUT"
  git -C "$CHECKOUT" fetch origin
  # This is a disposable installer-environment checkout, not user work, and
  # a destructive disko run is coming right up — never proceed on a stale or
  # locally-modified tree silently. Hard-reset to the remote default branch.
  DEFAULT_BRANCH="$(git -C "$CHECKOUT" remote show origin | sed -n 's/.*HEAD branch: //p')"
  git -C "$CHECKOUT" reset --hard "origin/${DEFAULT_BRANCH:-main}" \
    || die "could not fast-forward $CHECKOUT to origin/${DEFAULT_BRANCH:-main} — fix or delete $CHECKOUT and re-run"
else
  info "cloning $REPO_URL to $CHECKOUT"
  git clone "$REPO_URL" "$CHECKOUT"
fi
cd "$CHECKOUT"

# --- 2. master age key (from Vaultwarden, BEFORE disko) --------------------
CURRENT_STEP="fetching the master key from Vaultwarden"
# Fetched before the destructive step: if this fails (wrong Vaultwarden
# password, 2FA typo, network unreachable) you can abort with the disk
# still untouched instead of finding out after it's already wiped.
KEY_TMP=""
if [ "$NEEDS_MASTER_KEY" -eq 1 ]; then
  KEY_SRC=""
  if [ -n "${BW_KEY_FILE:-}" ] && [ -f "$BW_KEY_FILE" ]; then
    KEY_SRC="$BW_KEY_FILE"
    info "using key from BW_KEY_FILE=$BW_KEY_FILE"
  else
    command -v bw >/dev/null || die "bitwarden CLI not found in PATH"
    info "logging in to Vaultwarden ($BW_URL)"
    bw config server "$BW_URL" >/dev/null
    # Pre-emptive logout: if a previous run crashed between login and
    # logout (e.g. this same boot session, script re-run after a failure
    # further down), bw would otherwise refuse a second `bw login` with
    # "You are already logged in as X." Guarantee a clean slate.
    bw logout >/dev/null 2>&1 || true

    # `bw login` runs fully interactively here: it prompts for email,
    # master password, and (if enabled) the 2FA code — all handled by the
    # CLI itself, nothing scripted around it. `--raw` makes it print just
    # the session key on success (nothing captured on failure).
    BW_SESSION="$(bw login --raw)" \
      || die "bw login failed (wrong credentials/2FA, or Vaultwarden unreachable at $BW_URL?) — disk not touched yet"

    KEY_TMP="$(mktemp)"
    bw get notes "$BW_ITEM_NAME" --session "$BW_SESSION" > "$KEY_TMP" \
      || { bw logout >/dev/null 2>&1 || true; unset BW_SESSION; rm -f "$KEY_TMP"; die "could not read notes of item '$BW_ITEM_NAME' — disk not touched yet"; }
    chmod 600 "$KEY_TMP"
    bw logout >/dev/null 2>&1 || true
    unset BW_SESSION
    [ -s "$KEY_TMP" ] || { rm -f "$KEY_TMP"; die "item '$BW_ITEM_NAME' has an empty notes field — disk not touched yet"; }
    KEY_SRC="$KEY_TMP"
  fi
fi

# --- 3. disko ---------------------------------------------------------------
echo
echo "============================================================"
echo "  WARNING: about to DESTROY ALL DATA on the target disk"
echo "  host:    $HOST"
echo "  disko:   $DISKO_FILE"
echo "============================================================"
read -r -p "Type 'destroy' to continue: " ANSWER
[ "$ANSWER" = "destroy" ] || { [ -n "$KEY_TMP" ] && rm -f "$KEY_TMP"; die "aborted"; }

info "running disko (partition + format + mount)"
CURRENT_STEP="disko partitioning/formatting/encrypting the disk (check: did you retype the LUKS passphrase correctly?)"
[ -f "$DISKO_FILE" ] || die "disko config not found: $DISKO_FILE (does not exist in this repo yet)"
# --yes-wipe-all-disks skips disko's OWN separate 'type yes to wipe' prompt.
# We already got explicit confirmation above; a second identical prompt from
# disko itself is redundant, not extra safety.
nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest -- --mode destroy,format,mount --yes-wipe-all-disks "$DISKO_FILE"

# --- 3.5 swap keyfile (laptop) ----------------------------------------------
# The laptop's encrypted swap (cryptswap) is NOT enrolled in the TPM — it is
# unlocked with a keyfile on the (already TPM-unlocked) root filesystem,
# declared as boot.initrd.luks.devices.cryptswap.keyFile in
# hosts/laptop/hardware-configuration.nix. Generate that keyfile and add it
# to the swap container's LUKS header right after disko, so the fresh
# install boots with working, automatically-unlocked swap.
if [ "$HOST" = "laptop" ]; then
  SWAP_KEY_DST="/mnt/var/lib/luks-swap.key"
  SWAP_PART="/dev/disk/by-partlabel/disk-main-luksSwap"
  CURRENT_STEP="generating the swap unlock keyfile"
  info "generating swap keyfile at $SWAP_KEY_DST"
  mkdir -p "$(dirname "$SWAP_KEY_DST")"
  dd if=/dev/urandom of="$SWAP_KEY_DST" bs=4096 count=1
  chmod 600 "$SWAP_KEY_DST"
  CURRENT_STEP="adding the swap keyfile to the cryptswap LUKS header"
  cryptsetup luksAddKey "$SWAP_PART" "$SWAP_KEY_DST" \
    || die "could not add keyfile to $SWAP_PART — check the partition exists and the LUKS header is intact"
  info "swap keyfile enrolled"
fi

# --- 4. place master key -----------------------------------------------------
CURRENT_STEP="placing the master key onto the new install"
if [ "$NEEDS_MASTER_KEY" -eq 1 ]; then
  if [ -f "$KEY_DST" ]; then
    info "master key already in place at $KEY_DST"
  else
    info "placing master key at $KEY_DST"
    mkdir -p "$(dirname "$KEY_DST")"
    cp "$KEY_SRC" "$KEY_DST"
    chmod 700 "$(dirname "$KEY_DST")"
    chmod 600 "$KEY_DST"
    [ -n "$KEY_TMP" ] && rm -f "$KEY_TMP"
  fi
fi

# --- 5. install --------------------------------------------------------------
info "running nixos-install for $HOST"
CURRENT_STEP="nixos-install (building/installing the system)"
nixos-install --flake ".#$HOST"

info "install finished. Rebooting in 10s (Ctrl-C to cancel and stay in the installer)..."
sleep 10
systemctl reboot

# ===========================================================================
# POST-INSTALL (manual, one time): TPM2 enrollment of the root LUKS container
# ===========================================================================
# This CANNOT be automated here: systemd-cryptenroll seals the key against
# the PCR values of the *running* system. From the installer ISO those PCRs
# measure the installer kernel/Secure Boot state — not the freshly installed
# system — so a key sealed here would never be released at real boot. It also
# prompts interactively for the LUKS passphrase.
#
# After the first real boot (Lanzaboote has then enrolled its Secure Boot
# keys), run from a TTY on the laptop:
#
#   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 \
#     --wipe-slot=tpm2 /dev/disk/by-partlabel/disk-main-luksRoot
#
# See README.md, section "Secure Boot & TPM2 disk encryption (laptop)".
