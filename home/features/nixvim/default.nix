{ config, inputs, ... }:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim

    ./plugins
    ./ui

    ./lsp.nix
    ./mappings.nix
    ./settings.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;

    luaLoader.enable = true;

    # Highlight and remove extra white spaces
    highlight.ExtraWhitespace.bg = "red";
    match.ExtraWhitespace = "\\s\\+$";
  };
}
