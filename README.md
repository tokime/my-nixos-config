# NixOS Configuration

My personal NixOS configuration.

The system is managed with flakes. Home Manager is integrated as a NixOS module, so user packages and dotfiles are applied together with the system rebuild.

## Layout

```text
.
├── flake.nix
├── flake.lock
├── hosts/
│   └── nixos/
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── modules/
│   ├── boot.nix
│   ├── desktop.nix
│   ├── networking.nix
│   ├── nvidia.nix
│   └── packages.nix
└── users/
    └── artem/
        ├── home.nix
        └── nixos.nix
```

## Files

- `flake.nix`: entry point, inputs, and NixOS configuration wiring.
- `hosts/nixos/configuration.nix`: host-level configuration and module imports.
- `hosts/nixos/hardware-configuration.nix`: machine-specific hardware and filesystem mounts.
- `modules/`: reusable system modules.
- `users/artem/nixos.nix`: NixOS user account configuration.
- `users/artem/home.nix`: Home Manager configuration.

`hardware-configuration.nix` is tracked because the flake imports it during evaluation. Filesystems are referenced by labels instead of UUIDs:

```text
/dev/disk/by-label/nixos
/dev/disk/by-label/NIXBOOT
```

## Apply

```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

## Check

```bash
nixos-rebuild dry-build --flake path:/etc/nixos#nixos
```

## Update Inputs

```bash
nix flake update /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

## New Machine Notes

Generate hardware configuration:

```bash
sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
```

If using this configuration as-is, create matching filesystem labels before rebuilding:

```bash
sudo btrfs filesystem label / nixos
sudo fatlabel /dev/disk/by-uuid/<BOOT-UUID> NIXBOOT
```

Then verify:

```bash
lsblk -f
```
