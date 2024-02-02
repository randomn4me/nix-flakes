{
  imports = [
    ./lualine.nix
  ];

  programs.nixvim = {
    colorschemes.tokyonight = {
      enable = true;
      style = "night";
    };

    plugins.notify.enable = true;
  };
}

