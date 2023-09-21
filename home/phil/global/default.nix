{ inputs, lib, pkgs, config, outputs, ... }:
let
  inherit (inputs.nix-colors) colorSchemes;
in
{
  imports = [
    inputs.nix-colors.homeManagerModule
    ../features/cli
    ../features/nvim
  ];# ++ (builtins.attrValues outputs.homeManagerModules);

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicat = (_: true);
    };
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = false;
    };
  };

  programs = {
    home-manager.enable = true;
    git.enable = true;
  };

  home = {
    username = lib.mkDefault "phil";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.05";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      FLAKE = "$HOME/etc";
      XDG_DESKTOP_HOME = "$HOME/tmp";
      XDG_DOWNLOAD_HOME = "$HOME/tmp";
      XDG_DOCUMENTS_HOME = "$HOME/usr/docs";
      XDG_MUSIC_HOME = "$HOME/usr/music";
      XDG_PICTURES_HOME = "$HOME/usr/pics";
      XDG_VIDEOS_HOME = "$HOME/usr/vids";
    };
  };

  xdg = {
    enable = true;
    #userDirs = {
    #  desktop = "${config.home.homeDirectory}/tmp";
    #  download = "${config.home.homeDirectory}/tmp";
    #  documents = "${config.home.homeDirectory}/usr/docs";
    #  music = "${config.home.homeDirectory}/usr/music";
    #  pictures = "${config.home.homeDirectory}/usr/pics";
    #  videos = "${config.home.homeDirectory}/usr/vids";

    #  createDirectories = true;
    #};
  };

  colorscheme = lib.mkDefault colorSchemes.rose-pine;
  #home.file.".colorscheme".text = config.colorscheme.rose-pine; # TODO what's that
}
