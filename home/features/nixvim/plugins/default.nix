{
  imports = [
    ./fugitive.nix
    ./harpoon.nix
    ./lsp.nix
    #./obsidian.nix
    ./telescope.nix
    ./todo-comments.nix
    ./treesitter.nix
    ./vimtex.nix
  ];

  programs.nixvim.plugins = {
    gitsigns.enable = true;
    leap.enable = true;
    lualine.enable = true;
    lsp-format.enable = true;
    neogen.enable = true;
    notify.enable = true;
    trouble.enable = true;
    nvim-colorizer.enable = true;
  };
}
