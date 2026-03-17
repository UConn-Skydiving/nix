{
  modulesPath,
  lib,
  pkgs,
  ...
} @ args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    # ./auto-upgrade.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # SSHD options
  # see params here: https://nixos.wiki/wiki/SSH
  services.openssh.enable = true;


  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.root.openssh.authorizedKeys.keys =
  [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAqEzDmGqRBgsRZmIph2EWPMK2o1z5DdoMfVAhuMg9oW aidan@aidanw.org"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElm2BsjfEl//St8lBlguayNVmrP24e86cZjlBiinR4j aidanw@nixos"
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 30;
  };

  system.stateVersion = "24.05";
}
