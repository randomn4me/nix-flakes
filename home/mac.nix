{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}:
{
  imports = [
    ./features/desktop/common/kitty.nix
    ./features/cli

    ./features/productivity/taskwarrior.nix

    ./features/ssh/peasec.nix
    ./features/ssh/private.nix

  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicat = (_: true);
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "repl-flake"
      ];
      warn-dirty = false;
    };
  };

  home.packages = with pkgs; [
    devenv
    just
    element-desktop
    tmux-sessionizer
    texliveFull
    zathura
    cargo
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ".." = "cd ..";

      # saveguard
      rm = "rm -i";
      mv = "mv -i";

      # shorter
      cp = "cp -r";
      mkdir = "mkdir -p";

      cal = "cal -m";
      vim = "nvim";
      vi = "nvim";
    };

    history = {
      size = 10000;
    };
  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.05";
}
