{
  imports = [
    ./ncmpcpp.nix
    ./mopidy.nix
  ];

  services.mpris-proxy.enable = true;
}
