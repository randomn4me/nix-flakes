# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.

{
  monitors = import ./monitors.nix;
  wallpaper = import ./wallpaper.nix;

  mpd = import ./mpd.nix;
  nvim = import ./nvim;
  rbw = import ./rbw.nix;
  gc = import ./gc.nix;
  #desktop = import ./desktop;
}
