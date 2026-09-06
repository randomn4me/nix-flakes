{ inputs, ... }:
{
  imports = [
    ./global
    ./features/ssh/private.nix
  ];

  systemd.user.startServices = "sd-switch";

  custom.nvim.enable = true;
  custom.nvim.allPlugins = false;

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;
}
