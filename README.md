# NixOS Config

My personal NixOS configuration, managed declaratively with [flakes](https://nixos.wiki/wiki/Flakes) and [Home Manager](https://github.com/nix-community/home-manager). Secrets are encrypted in-repo with [sops-nix](https://github.com/Mic92/sops-nix).

## Machines

| Host | Hardware | Desktop | Networking |
|---|---|---|---|
| `laptop` | Dell XPS 13 9370 (4K) | Hyprland + Waybar | wpa_supplicant (`networking.wireless`), disko-managed LUKS disk layout |
| `gaming-pc` | Custom (RTX 3070) | KDE Plasma | NetworkManager |

## Structure

```
.
├── flake.nix                  # Entry point: inputs + nixosConfigurations for each host
├── flake.lock                 # Locked input versions for reproducibility
├── .sops.yaml                 # sops creation rules: which age keys encrypt which secrets files
├── hosts/
│   ├── laptop/
│   │   ├── configuration.nix  # Host config (incl. sops secrets + Wi-Fi template)
│   │   ├── hardware-configuration.nix
│   │   ├── disko.nix          # Declarative disk partitioning (ESP, LUKS swap/root)
│   │   └── secrets.yaml       # sops-encrypted secrets (safe to commit)
│   └── gaming-pc/
│       ├── configuration.nix
│       ├── hardware-configuration.nix
│       └── secrets.yaml
├── home/                      # Home Manager configs per host (nvim, hyprland, waybar, ...)
├── modules/                   # Reusable feature modules (git, nvim, hyprland, steam, ...)
└── roles/                     # Composable role bundles (base, development, gaming, ...)
```

Hosts compose `roles/`, roles import `modules/`. Nothing host-specific lives in shared roles or modules.

## Secrets management (sops-nix)

### How it works

- Each host has its own `hosts/<host>/secrets.yaml`, encrypted with [sops](https://github.com/getsops/sops) and committed to the repo (ciphertext in git is fine — that's the point).
- `.sops.yaml` in the repo root defines **creation rules**: which age public keys each secrets file is encrypted against. sops picks the right rule automatically based on the file path.
- Secrets are encrypted against **multiple recipients** (any one of the private keys can decrypt):
  - `master_age_key` — a standalone age key stored as a **secure note (`master-age-key`) in the self-hosted Vaultwarden** (and on the rescue USB as backup). It is never committed to this repo and can decrypt everything in an emergency.
  - The hosts' SSH host keys / user SSH keys (public halves, converted to age format via `ssh-to-age`).
- **The laptop decrypts with the master age key** (`age.keyFile = "/var/lib/sops/age/master.key"` in `hosts/laptop/configuration.nix`). That file is root-only on the LUKS-encrypted disk. Semantics: when `age.keyFile` is set it is the **only** identity — `age.sshKeyPaths` is ignored, and a missing file makes decryption fail hard. Keep backups of the master key (USB + Bitwarden).
- **The gaming PC decrypts with its SSH host key** (`age.sshKeyPaths`, no `age.keyFile`).
- **SSH host keys are NOT secrets.** They are regular sshd-generated files (`/etc/ssh/ssh_host_*`), not delivered by sops. Do not add them back to `secrets.yaml`: a decryption identity that is itself a sops secret is a chicken-and-egg loop — the key needed to decrypt the secrets doesn't exist until after decryption. This took the laptop down at boot (no Wi-Fi PSK → no network, sshd without a host key) until it was removed.

### Installing / reinstalling a machine

One command from the installer ISO does everything (clone → disko → master key → `nixos-install`):

```bash
sudo nix --experimental-features "nix-command flakes" run github:danielvollbro/dotfiles#laptop-install
# or: ...#gaming-pc-install
```

The script (`installer/bootstrap.sh`) clones the repo, then:

1. **laptop only:** fetches the master age key from Vaultwarden — `bw login` interactively prompts for your Vaultwarden email, master password and 2FA code (nothing scripted around the prompts), then reads the key from the secure note `master-age-key` (override with `BW_ITEM_NAME`; point `BW_KEY_FILE` at a local file to skip Vaultwarden entirely) and logs out. **Fetched before the disk is touched**, so a wrong password/2FA/network issue aborts safely with nothing destroyed yet.
2. asks for a `destroy` confirmation, prompts for the LUKS passphrase (with a retry loop — a mismatch just asks again, nothing is touched yet), then wipes, partitions and mounts the target disk via the host's `disko.nix` (disko's own separate confirmation prompt is skipped with `--yes-wipe-all-disks` — you already confirmed once). Root's own password prompt during `nixos-install` is skipped on hosts whose user password is already set declaratively via sops (currently: laptop) — nothing to mistype there either.
3. places the master key at `/mnt/var/lib/sops/age/master.key` with `0600`.
4. runs `nixos-install --flake .#<host>`.

If any step fails (wrong password, mistyped LUKS passphrase, network drop, build error), the script prints which step it was on and what to check, instead of just silently dying. Just re-run the same command to retry from the top — the checkout, master-key fetch and disko steps are all safe to repeat.

Once `nixos-install` succeeds the script automatically reboots after a 10s countdown (Ctrl-C to cancel and stay in the installer shell instead).

**First login:** if the target host has `USER_PASSWORD_HASH` in its `secrets.yaml` (currently: laptop), your user password is set declaratively via sops on first boot — nothing to do. Hosts without that secret still need the old manual flow: log in as root, `passwd <user>`.

Hosts using `sshKeyPaths` (gaming-pc) don't need a master key; their host key can be pre-generated before install to keep the same fingerprint across reinstalls (otherwise expect `REMOTE HOST IDENTIFICATION HAS CHANGED` on clients — fix with `ssh-keygen -R <host>`).

<details>
<summary>Manual steps (what the script automates)</summary>

1. Boot the NixOS installer (Ventoy USB), mount your target at `/mnt` as usual, and clone the repo.
2. Provide the decryption identity for the installed system:
   - **Laptop (master key):** place the master age key where the config expects it (retrieve it from Vaultwarden — secure note `master-age-key` — or wherever else you keep a copy):
     ```bash
     sudo mkdir -p /mnt/var/lib/sops/age
     sudo cp /path/to/master-age.key /mnt/var/lib/sops/age/master.key
     sudo chmod 700 /mnt/var/lib/sops/age && sudo chmod 600 /mnt/var/lib/sops/age/master.key
     ```
   - **Hosts using `sshKeyPaths` (gaming-pc):** pre-generate SSH host keys so they don't rotate on reinstall:
     ```bash
     sudo mkdir -p /mnt/etc/ssh && sudo ssh-keygen -t ed25519 -f /mnt/etc/ssh/ssh_host_ed25519_key -N ""
     ```
3. Install:
   ```bash
   sudo nixos-install --flake ~/code/nixos#laptop
   ```
4. Reboot. From the first activation onwards, `sops-install-secrets` decrypts with the configured identity (master key on the laptop, SSH host key on `sshKeyPaths` hosts).

</details>

> **Rotating the SSH host key** (fresh keygen, or reinstall without step 2 on a `sshKeyPaths` host) changes the machine's fingerprint — expect `REMOTE HOST IDENTIFICATION HAS CHANGED` and update clients with `ssh-keygen -R <host>`.

### Adding a new secret

1. Add the key to the host's `secrets.yaml` (plaintext — you edit it with sops):
   ```bash
   export SOPS_AGE_KEY_FILE=/path/to/master-age.key   # or use any matching private key
   sops hosts/laptop/secrets.yaml
   ```
   sops encrypts on save using the matching `creation_rules` entry from `.sops.yaml`. It will warn if the file isn't yet in the rules.
2. Declare it in the host's `configuration.nix` under `sops.secrets`:
   ```nix
   sops.secrets.MY_NEW_SECRET = {
     owner = "root";        # user that owns /run/secrets/MY_NEW_SECRET
     mode = "0400";
     # path = "/custom/path";   # optional, defaults to /run/secrets/<NAME>
   };
   ```
3. Consume it at `/run/secrets/MY_NEW_SECRET` (or via a template, see below). Commit and `nixos-rebuild switch`.

### Adding a new host

1. Create `hosts/<new-host>/configuration.nix` (+ `hardware-configuration.nix`), import it in `flake.nix`, and add `sops-nix.nixosModules.sops` to its modules.
2. Decide the decryption identity and add the corresponding **public** key (converted to age format) to `.sops.yaml`:
   - **Like the laptop** (`age.keyFile` → master key): no extra recipient needed beyond `master_age_key`.
   - **Like the gaming PC** (`age.sshKeyPaths` → host key): pre-generate the host's SSH keys and convert:
     ```bash
     ssh-keygen -t ed25519 -f ./ssh_host_ed25519_key
     nix run nixpkgs#ssh-to-age -- < ./ssh_host_ed25519_key.pub
     # → age1... — add as a .keys anchor + creation_rules entry
     ```
     The generated private key must be placed at `/mnt/etc/ssh/ssh_host_ed25519_key` during install (see reinstall step 2).
3. Create `hosts/<new-host>/secrets.yaml`, encrypt it (`sops --encrypt --in-place`), and follow the install steps above.
4. Referencing a host key in `.sops.yaml` before it's committed elsewhere is fine — sops only stores the public key.

### Gotchas

- **sops CLI vs NixOS:** `SOPS_AGE_KEY_FILE` only affects the `sops` CLI. `nixos-rebuild` decryption is done by `sops-install-secrets`, which uses `age.keyFile` (if set — and then *requires* that file to exist, with **no** fallback to `sshKeyPaths`) or `age.sshKeyPaths`. The laptop uses `keyFile` (master key), the gaming PC uses `sshKeyPaths`.
- **Chicken-and-egg:** never make a decryption identity itself a sops secret (e.g. SSH host key delivered by sops while it is also the key that decrypts) — the secrets won't exist at boot and the machine comes up without network/sshd.
- **Flakes ignore untracked files.** A new/changed `secrets.yaml` must be `git add`-ed (or committed) before `nixos-rebuild` sees it.
- **`--age` takes public keys**, not key files — get the age pubkey of a key with `age-keygen -y <keyfile>`, and convert SSH pubkeys with `ssh-to-age`.
- **Templates** (`sops.templates`) render secret *values* into files like the wpa_supplicant env file without ever putting plaintext in the nix store. Secrets referenced by a template are pulled in automatically via `config.sops.placeholder.<NAME>`.

## Secure Boot & TPM2 disk encryption (laptop)

The laptop unlocks its root LUKS container with the TPM2 chip at boot — no
passphrase prompt — gated on Secure Boot state, bootloader, kernel and kernel
command line (PCR 0+2+7+12). [Lanzaboote](https://github.com/nix-community/lanzaboote)
signs the bootloader and auto-generates/enrolls Secure Boot keys
(`boot.lanzaboote` in `hosts/laptop/configuration.nix`).

### First-time enrollment

After the first `nixos-rebuild switch` with Lanzaboote enabled (it reboots once
to enroll its Secure Boot keys), enroll the disk encryption key into the TPM —
run this from a TTY, not an SSH session, since it prompts for the LUKS passphrase:

```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 --wipe-slot=tpm2 \
  /dev/disk/by-partlabel/disk-main-luksRoot
```

### Encrypted swap

Swap (`cryptswap`) is **not** enrolled in the TPM — it is unlocked with a
keyfile living on the (already TPM-unlocked) root filesystem, declared via
`keyFile` in `hosts/laptop/hardware-configuration.nix`. To (re)generate it:

```bash
sudo dd if=/dev/urandom of=/var/lib/luks-swap.key bs=4096 count=1
sudo chmod 600 /var/lib/luks-swap.key
sudo cryptsetup luksAddKey /dev/disk/by-partlabel/disk-main-luksSwap /var/lib/luks-swap.key
```

### When the TPM prompt returns

The key is only released while the measured boot state is unchanged. After a
kernel/BootLoader-spec change, Secure Boot key rotation or firmware update the
machine falls back to asking for the LUKS passphrase — just re-run the
`systemd-cryptenroll` command above to re-bind the new state.

## Rebuilding

```bash
# Laptop
sudo nixos-rebuild switch --flake ~/code/nixos#laptop

# Gaming PC
sudo nixos-rebuild switch --flake ~/code/nixos#gaming-pc
```

The warning `Git tree '...' is dirty` just means uncommitted changes are being evaluated — fine for testing, but commit before you rely on a build.
