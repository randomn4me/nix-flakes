{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim

    ./plugins
    ./options.nix
    ./mappings.nix
  ];

  programs.nixvim = {
    enable = true;
    enableMan = true;

    defaultEditor = true;

    viAlias = true;
    vimAlias = true;

    colorschemes.tokyonight = {
      enable = true;
      style = "night";
    };
  };
}
