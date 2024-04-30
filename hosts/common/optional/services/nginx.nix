{
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedTlsSettings = true;
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
