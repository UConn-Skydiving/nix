{ ... }:
{
  # https://www.reddit.com/r/NixOS/comments/1cunvdw/comment/l600dnk/
  # Seems like we need this otherwise we don't actually get auto gc?
  # See above thread for more ^
  nix.optimise.automatic = true;

  # If we rebuild a lot in 30 days, this may be inadequate
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
