# modules/tests.nix
################################################################################
# Basic checks that jonathan and the VM package evaluate as expected.
################################################################################

{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    let
      checkCond = name: cond:
        pkgs.runCommandLocal name { } (if cond then "touch $out" else "");

      jonathan = inputs.self.nixosConfigurations.jonathan.config;
      jonathanBuilds =
        !pkgs.stdenvNoCC.isLinux
        || builtins.pathExists (jonathan.system.build.toplevel);
      vmBuilds =
        !(pkgs.stdenvNoCC.isLinux || pkgs.stdenvNoCC.isDarwin)
        || builtins.pathExists (self'.packages.vm + "/bin/vm");
    in
    {
      checks."jonathan builds" = checkCond "jonathan-builds" jonathanBuilds;
      checks."vm builds" = checkCond "vm-builds" vmBuilds;
    };
}
