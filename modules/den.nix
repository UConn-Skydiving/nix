# modules/den.nix
################################################################################
# Host declarations live here.
# Example usage:
# {
#   den.hosts.aarch64-linux.jonathan = { };
#   den.hosts.x86_64-linux.backup = { };
#   den.hosts.x86_64-linux.igloo.users.alice = { };
#   den.hosts.aarch64-darwin.apple.users.alice = { };
#   den.homes.x86_64-linux.alice = { };
# }
#
# One user (alice) across a NixOS host, a Darwin host, and a standalone 
# Home-Manager config. The same aspects produce appropriate configs for each
# platform. This repository is currently host-focused. User/home declarations 
# can be added later if we move to a multi-user setup.
################################################################################

{
  den.hosts.aarch64-linux.jonathan = { };
}
