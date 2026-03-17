{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

  outputs =
    {
      nixpkgs,
      disko,
      nixos-facter-modules,
      ...
    }:
    {
      # tested with 2GB/2CPU droplet, 1GB droplets do not have enough RAM for kexec
      nixosConfigurations.netcup = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          disko.nixosModules.disko
          { disko.devices.disk.disk1.device = "/dev/vda"; }
          ./configuration.nix
      	  ./hardware-configuration.nix
          ./auto-upgrade.nix
        ];
      };
      nixosConfigurations.generic-aarch64 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
        ];
      };

      # Use this for all other targets
      # nixos-anywhere --flake .#generic --generate-hardware-config nixos-generate-config ./hardware-configuration.nix <hostname>
      nixosConfigurations.generic = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          ./hardware-configuration.nix
        ];
      };
    };
}
