{ pkgs, inputs, ... }:
{
  imports = [
    ./global

    ./features/ssh/private.nix

    ./features/nixvim
    ./features/backup
  ];

  systemd.user.startServices = "sd-switch";

  programs.nixvim.plugins = {
    lsp.enable = false;
    luasnip.enable = false;
    lspkind.enable = false;
    cmp.enable = false;
  };

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;
}
