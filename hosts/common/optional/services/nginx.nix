{
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
