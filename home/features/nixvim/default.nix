{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim

    ./completion.nix
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

    # Highlight and remove extra white spaces
    highlight.ExtraWhitespace.bg = "red";
    match.ExtraWhitespace = "\\s\\+$";
  };
}
