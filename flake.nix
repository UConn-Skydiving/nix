{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # Use nixpkgs-unstable instead of master so that packages are more likely
    # to be cached already while still being as fresh as possible.
    # See https://discourse.nixos.org/t/differences-between-nix-channels/13998
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    disko,
    self,
    ...
  } @ inputs: let
   # Helper for making nixOS system from common modules
   buildSystem = { hostname, system ? [ "aarch64-linux" ]} : 
   nixpkgs.lib.nixosSystem {                                                       
     inherit system;
     specialArgs = {inherit (self) inputs outputs;};
     modules = [
       ./hosts/${hostname}
       # Enforce consistent host name.
       { networking.hostName = hostname; }
     ];
   };
  in {

    nixosConfigurations = {
        jonathan = buildSystem "jonathan" "aarch64-linux";
    };

    # 2GB/2CPU seems to be the minimum for kexec. Don't try 1GB RAM.
    #nixosConfigurations.netcup = nixpkgs.lib.nixosSystem {
    #  system = "aarch64-linux";
    #  modules = [
    #    disko.nixosModules.disko
    #    { disko.devices.disk.disk1.device = "/dev/vda"; }
    #    ./configuration.nix
    #	  ./hardware-configuration.nix
    #    ./auto-upgrade.nix
    #  ];
    #};
    #nixosConfigurations.generic-aarch64 = nixpkgs.lib.nixosSystem {
    #  system = "aarch64-linux";
    #  modules = [
    #    disko.nixosModules.disko
    #    ./configuration.nix
    #  ];
    #};     
  };
}
