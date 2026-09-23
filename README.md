# NixOS Config

My personal NixOS configuration, managed declaratively with [flakes](https://nixos.wiki/wiki/Flakes) and [Home Manager](https://github.com/nix-community/home-manager).

## Setup

- **Machine:** Dell XPS 13 9370 (4K display)
- **Window Manager:** [Hyprland](https://hyprland.org/)
- **Status bar:** Waybar
- **Login manager:** greetd + tuigreet
- **Networking:** `networking.wireless` (wpa_supplicant) with an encrypted password via `secretsFile`

## Structure

```
.
├── flake.nix               # Entry point, defines inputs and outputs
├── flake.lock              # Locked versions for reproducibility
├── hosts/
│   └── laptop/
│       ├── configuration.nix          # System config for the laptop
│       └── hardware-configuration.nix # Auto-generated hardware config
└── home/
    ├── home.nix             # Home Manager config (user-level)
    ├── hypr/                # Hyprland config
    └── waybar/              # Waybar config
```

## Installing on a new machine

1. Clone the repo:
   ```bash
   git clone git@github.com:yourusername/nixos-config.git ~/nixos-config
   ```

2. Create the wifi secrets file (not committed to the repo):
   ```bash
   sudo mkdir -p /etc/nixos-secrets
   sudo nano /etc/nixos-secrets/wireless.env
   ```
   Content:
   ```
   wifi_psk=YourPassword
   ```
   ```bash
   sudo chown wpa_supplicant:wpa_supplicant /etc/nixos-secrets/wireless.env
   sudo chmod 600 /etc/nixos-secrets/wireless.env
   ```

3. Symlink `/etc/nixos` to the repo:
   ```bash
   sudo mv /etc/nixos /etc/nixos.bak
   sudo ln -s ~/nixos-config /etc/nixos
   ```

4. Build:
   ```bash
   sudo nixos-rebuild switch --flake ~/nixos-config#laptop
   ```
