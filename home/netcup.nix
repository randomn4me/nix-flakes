{ inputs, ... }:
{
  imports = [
    ./global

    ./features/ssh/peasec.nix
    ./features/ssh/private.nix
  ];

  systemd.user.startServices = "sd-switch";
  custom.nvim.enable = true;

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;
}
