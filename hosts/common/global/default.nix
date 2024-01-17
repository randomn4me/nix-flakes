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

    (pkgs.nerdfonts.override { fonts = [ "ShareTechMono" ]; })
  ];

  nixpkgs = { config = { allowUnfree = true; }; };

  console = { keyMap = "de"; };
}
