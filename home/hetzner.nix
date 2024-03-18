{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./global

    ./features/ssh/private.nix

    ./features/nixvim
    ./features/backup
  ];

  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [
    comma
    gnumake
  ];

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;
}
