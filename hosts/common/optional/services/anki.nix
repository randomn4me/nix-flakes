{
  imports = [
    ./nginx.nix
    ./acme.nix
  ];

  services.ankisyncd = {
    enable = true;
    openFirewall = true;
  };
}

