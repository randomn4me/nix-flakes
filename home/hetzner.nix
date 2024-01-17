{ pkgs, inputs, lib, ... }: {
  imports = [
    ./global

    ./features/ssh/private.nix

    ./features/backup
  ];

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = false;
    };
  };

  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [
    comma
    gnumake
  ];

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;
}

