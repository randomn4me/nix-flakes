{ config, ... }:
{
    imports = [
        ./harpoon.nix
        ./fugitive.nix
        ./telescope.nix
        ./treesitter.nix
        ./neo-tree.nix
        ./toggleterm.nix
        ./vimtex.nix
    ];

  programs.nixvim.plugins = {
    bufferline.enable = true;
    neo-tree.enable = true;
    which-key.enable = true;
    leap.enable = true;

    vimtex = {
      enable = true;
      viewMethod = if config.programs.zathura.enable then "zathura" else "general";
    };

  };
}
