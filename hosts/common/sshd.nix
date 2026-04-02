{ ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      UseDns = true;
      X11Forwarding = true;
      # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
      PermitRootLogin = "prohibit-password";
      PrintMotd = true;
    };
  };

  # lists are merged by default. This does not override any other allowedTCPPorts
  # networking.firewall.allowedTCPPorts = [ 22 ];
}
