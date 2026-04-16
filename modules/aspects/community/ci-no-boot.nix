# modules/aspects/community/ci-no-boot.nix
################################################################################
# Disables host boot requirements for CI-only evaluation.
################################################################################

{
  community.ci-no-boot = {
    description = "Disables booting during CI";
    nixos = {
      boot.loader.grub.enable = false;
      fileSystems."/".device = "/dev/null";
    };
  };
}
