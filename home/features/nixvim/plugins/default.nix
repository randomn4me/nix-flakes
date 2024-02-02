{
  imports = [
    ./fugitive.nix
    ./harpoon.nix
    ./telescope.nix
    ./treesitter.nix
    ./vimtex.nix
  ];

  programs.nixvim.plugins = {
    gitsigns.enable = true;
    leap.enable = true;
    which-key.enable = true;
  };
}
