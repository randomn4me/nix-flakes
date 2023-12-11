{ inputs, lib, pkgs, config, outputs, ... }:
let inherit (inputs.nix-colors) colorSchemes;
in {
  imports =
    [ inputs.nix-colors.homeManagerModule ../features/cli ../features/nvim ]
    ++ (builtins.attrValues outputs.homeManagerModules);

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
    sessionVariables.FLAKE = "${config.home.homeDirectory}/etc";
  };

  home.file."var/misc/r4ndom".text = builtins.readFile ./r4ndom.txt;

  systemd.user.startServices = "sd-switch";

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "${config.home.homeDirectory}/tmp";
      documents = "${config.home.homeDirectory}/usr/docs";
      download = "${config.home.homeDirectory}/tmp";
      music = "${config.home.homeDirectory}/usr/music";
      pictures = "${config.home.homeDirectory}/usr/pics";
      publicShare = "${config.home.homeDirectory}/var/share";
      templates = "${config.home.homeDirectory}/var/templates";
      videos = "${config.home.homeDirectory}/usr/vids";
    };
  };

  colorscheme = lib.mkDefault colorSchemes.rose-pine;
  home.file.".colorscheme".text = config.colorscheme.slug;
}
