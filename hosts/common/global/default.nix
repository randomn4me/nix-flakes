{ pkgs, ... }:

{
  imports = [ ./locale.nix ./nix.nix ./pkgs.nix ];

  fonts.packages = with pkgs; [
    fira
    fira-mono
    roboto
    roboto-mono
    roboto-serif
    libertine
    inconsolata
    inconsolata-nerdfont
    vistafonts

    google-fonts
  ];

  nixpkgs = { config = { allowUnfree = true; }; };

  console = { keyMap = "de"; };
}
