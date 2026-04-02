# Copilot Instructions for nixos-anywhere-examples

This repository contains NixOS configuration examples for deploying systems with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere), focusing on remote server deployments.

## Build Commands

Build a specific host configuration:
```bash
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

Build the current default configuration:
```bash
nix build
```

Show all flake outputs:
```bash
nix flake show
```

Check flake for errors:
```bash
nix flake check
```

## Architecture Overview

### Flake Structure

The repository uses a **Nix flake-based architecture** with these key components:

1. **`flake.nix`**: Entry point defining inputs (nixpkgs, disko, sops-nix) and a `buildSystem` helper function that standardizes host creation
2. **`hosts/<hostname>/`**: Per-host configurations, each containing:
   - `configuration.nix` - Main host config with boot, SSH, packages
   - `hardware-configuration.nix` - Hardware-specific settings (auto-generated, do not modify manually)
   - `disk-config.nix` - Disko declarative disk partitioning
   - `<hostname>.nix` - Host-specific overrides (optional)
3. **`hosts/common/`**: Shared modules imported by individual hosts

### Module System Patterns

**Common modules are opt-in**: Individual host configurations explicitly import only the `hosts/common/` modules they need. Common modules are not automatically applied to all hosts.

**List merging**: NixOS merges lists by default (e.g., `networking.firewall.allowedTCPPorts`). Common modules can add items without overriding host-specific settings.

**Helper function**: The `buildSystem` function in `flake.nix` encapsulates the standard pattern:
- Sets `nixpkgs.hostPlatform` (modern approach, not deprecated `system`)
- Enforces hostname from function parameter
- Imports from `./hosts/${hostname}`
- Passes through `inputs` and `outputs` as `specialArgs`

### Key Dependencies

- **disko**: Declarative disk partitioning (see `disk-config.nix` files)
- **sops-nix**: Secrets management (referenced in `tailscale.nix` via `config.age.secrets`)
- **nixpkgs**: Uses `nixos-unstable-small` channel for fast updates suitable for servers

## Key Conventions

### File Organization

- **Host-specific config**: `hosts/<hostname>/configuration.nix` is the primary entry point for a host
- **Reusable modules**: Place in `hosts/common/` with descriptive names (e.g., `sshd.nix`, `garbage-collection.nix`)
- **Disk layouts**: Always define in `disk-config.nix` using disko's declarative format

### NixOS Module Style

- Use `lib.mkDefault` for values that should be overridable (see `disk-config.nix` device paths and `hardware-configuration.nix` platform)
- Import `modulesPath` for standard NixOS profiles (e.g., `"${modulesPath}/profiles/qemu-guest.nix"`)
- Enable experimental features in host config: `nix.settings.experimental-features = [ "nix-command" "flakes" ]`

### SSH Configuration

- Root SSH access: Add authorized keys to `users.users.root.openssh.authorizedKeys.keys`
- Security defaults: Password authentication is disabled, prefer `PermitRootLogin = "prohibit-password"`
- SSH is opened via `services.openssh.enable = true` (firewall automatically allows port 22)

### Disko Patterns

Standard disk setup uses:
- GPT partition table with BIOS boot (1M EF02), ESP (500M EF00), and LVM root
- LVM provides flexibility for resizing
- `lib.mkDefault "/dev/sda"` allows override per host

### Common Module Reference

Available reusable modules in `hosts/common/`:
- `auto-upgrade.nix` - Automatic system updates from flake (configure `flake` URL and schedule)
- `garbage-collection.nix` - Automatic nix store cleanup (weekly, 30-day retention)
- `sshd.nix` - Hardened SSH server defaults
- `tailscale.nix` - VPN with firewall trust (requires sops-nix secret for auth key)
- `firewall.nix` - Basic firewall configuration
- `default.nix` - Minimal common settings (timezone)

### State Version

Always set `system.stateVersion` to the NixOS version when the system was first installed. Do not change this on existing systems.
