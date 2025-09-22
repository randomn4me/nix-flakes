{ inputs, ... }:
{
  imports = [
    ./global

    ./features/ssh/peasec.nix
    ./features/ssh/private.nix
  ];

  systemd.user.startServices = "sd-switch";

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;
}
