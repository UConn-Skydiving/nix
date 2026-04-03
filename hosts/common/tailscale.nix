_: {
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.age.secrets.vpn-preauth.path;
    extraUpFlags = [
      "--accept-dns=false" # if its' a server you prolly dont need magicdns
    ];
  };

  # Tell the firewall to implicitly trust packets routed over Tailscale:
  networking.firewall.trustedInterfaces = ["tailscale0"];
}
