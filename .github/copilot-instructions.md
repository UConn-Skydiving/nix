# Copilot Instructions for nixos-anywhere-examples

This repository contains NixOS configuration for deploying systems with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere), focusing on remote server deployments.
The systems are primarily meant to host services specific to UConn Skydiving.

## Build Commands

Test a specific host configuration:
```bash
nix run github:nix-community/nixos-anywhere -- --flake .#<configuration name> --vm-test
```

Build a specific host configuration to remote:
```bash
nix run github:nix-community/nixos-anywhere -- --flake .#<configuration name> --target-host root@<ip address>
```

Show all flake outputs:
```bash
nix flake show
```

Check flake for errors:
```bash
nix flake check
```

Before commiting, make sure to create the pre-commit files by running
```bash
nix develop
```

## Architecture Overview

### Flake Structure

The repository uses a **Nix flake-based architecture** with these key components:

1. **`flake.nix`**: Entry point defining inputs (nixpkgs, disko, sops-nix) and a `buildSystem` helper function that standardizes host creation
2. **`hosts/<hostname>/`**: Per-host configurations, each containing:
   - `default.nix` - Main host config with imports to other configurations
   - `hardware-configuration.nix` - Hardware-specific settings (auto-generated, do not modify manually)
   - `disk-config.nix` - Disko declarative disk partitioning
3. **`hosts/common/`**: Shared modules imported by individual hosts

### Module System Patterns

**Common modules are opt-in**: Individual host configurations explicitly import only the `hosts/common/` modules they need. Common modules are not automatically applied to all hosts.

**Helper function**: The `buildSystem` function in `flake.nix` encapsulates the standard pattern:
- Sets `nixpkgs.hostPlatform` (modern approach, not deprecated `system`)
- Enforces hostname from function parameter
- Imports from `./hosts/${hostname}`
- Passes through `inputs` and `outputs` as `specialArgs`

### Key Dependencies

- **disko**: Declarative disk partitioning (see `disk-config.nix` files)
- **nixpkgs**: Uses `nixos-unstable-small` channel for fast updates suitable for servers
- **git-hooks**: lints and enforces style before commiting

## Key Conventions

### File Organization

- **Host-specific config**: `hosts/<hostname>/configuration.nix` is the primary entry point for a host
- **Reusable modules**: Place in `hosts/common/` with descriptive names (e.g., `sshd.nix`, `garbage-collection.nix`)
- **Disk layouts**: Always define in `disk-config.nix` using disko's declarative format

### NixOS Module Style

- Use `lib.mkDefault` for values that should be overridable (see `disk-config.nix` device paths and `hardware-configuration.nix` platform)
- Import `modulesPath` for standard NixOS profiles (e.g., `"${modulesPath}/profiles/qemu-guest.nix"`)
- Enable experimental features in host config: `nix.settings.experimental-features = [ "nix-command" "flakes" ]`

### Security Practices
- Always give the least privileges a program requires
- SSH should never be accessible from outside a VPN (tailscale, wireguard)


### State Version

Always set `system.stateVersion` to the NixOS version when the system was first installed. Do not change this on existing systems.
