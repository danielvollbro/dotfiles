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
- Every host's secrets are encrypted against **multiple recipients**:
  - `master_age_key` — a standalone age key that lives **only on the install/rescue USB** (Ventoy). It is never stored on any machine and can decrypt everything in an emergency.
  - The host's own SSH host key (converted to age format via `ssh-to-age`).
  - (laptop only) the user SSH key.
- At activation, `sops-install-secrets` uses the host's SSH host key (via `age.sshKeyPaths` in each host's `configuration.nix`) as its age identity to decrypt. **No `age.keyFile` is set on purpose** — the master key must never be required at rest on a machine.
- The SSH host key *itself* is delivered by sops (`SSH_HOST_ED25519_KEY` secret written to `/etc/ssh/ssh_host_ed25519_key`), so it survives reinstalls unchanged — your `known_hosts` entries keep working, and the key is always available to decrypt the next boot's secrets.

### Installing / reinstalling a machine

The only manual secret step happens in the installer environment, before `nixos-install`:

1. Boot the NixOS installer (Ventoy USB), mount your target at `/mnt` as usual, and clone the repo.
2. Extract the host's SSH key from its secrets file using the master key from the USB:
   ```bash
   export SOPS_AGE_KEY_FILE=/mnt/master-age.key   # adjust to your USB mount point

   sops -d --extract '["SSH_HOST_ED25519_KEY"]' hosts/laptop/secrets.yaml \
     | sudo tee /mnt/etc/ssh/ssh_host_ed25519_key > /dev/null
   sudo chmod 600 /mnt/etc/ssh/ssh_host_ed25519_key

   sops -d --extract '["SSH_HOST_ED25519_PUB_KEY"]' hosts/laptop/secrets.yaml \
     | sudo tee /mnt/etc/ssh/ssh_host_ed25519_key.pub > /dev/null
   ```
3. Install:
   ```bash
   sudo nixos-install --flake ~/code/nixos#laptop
   ```
4. Reboot. From the first activation onwards, `sops-install-secrets` decrypts everything with the host key — the master key is no longer needed and the USB can be removed.

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
2. Generate/collect the host's SSH keys and add its **public** key (converted to age format) to `.sops.yaml`:
   ```bash
   ssh-keygen -t ed25519 -f ./ssh_host_ed25519_key
   nix run nixpkgs#ssh-to-age -- < ./ssh_host_ed25519_key.pub
   # → age1... — add as a .keys anchor + creation_rules entry
   ```
3. Create `hosts/<new-host>/secrets.yaml` with at least `SSH_HOST_ED25519_KEY` / `SSH_HOST_ED25519_PUB_KEY`, encrypt it (`sops --encrypt --in-place`), and follow the install steps above.
4. Referencing the host key in `.sops.yaml` before it's committed elsewhere is fine — sops only stores the public key, the private half travels via the secrets file itself.

### Gotchas

- **sops CLI vs NixOS:** `SOPS_AGE_KEY_FILE` only affects the `sops` CLI. `nixos-rebuild` decryption is done by `sops-install-secrets`, which uses `age.keyFile` (if set — and then *requires* that file to exist) or `age.sshKeyPaths`. This repo deliberately uses only `sshKeyPaths`.
- **Flakes ignore untracked files.** A new/changed `secrets.yaml` must be `git add`-ed (or committed) before `nixos-rebuild` sees it.
- **`--age` takes public keys**, not key files — get the age pubkey of a key with `age-keygen -y <keyfile>`, and convert SSH pubkeys with `ssh-to-age`.
- **Templates** (`sops.templates`) render secret *values* into files like the wpa_supplicant env file without ever putting plaintext in the nix store. Secrets referenced by a template are pulled in automatically via `config.sops.placeholder.<NAME>`.

## Rebuilding

```bash
# Laptop
sudo nixos-rebuild switch --flake ~/code/nixos#laptop

# Gaming PC
sudo nixos-rebuild switch --flake ~/code/nixos#gaming-pc
```

The warning `Git tree '...' is dirty` just means uncommitted changes are being evaluated — fine for testing, but commit before you rely on a build.
