# We assume that were installing this profile with nixOS-anywhere.
# As such, we need to set up the disks. Netcup servers use /dev/vda instead of the typical /dev/sda.
# If we change hosts, we need to update the disko device name to match. This can be found by running
# lsblk on the target machine.
{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ../common/disk-config.nix
  ];

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already}}
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  disko.devices.disk.disk1.device = "/dev/vda";

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 30;
  };
}
