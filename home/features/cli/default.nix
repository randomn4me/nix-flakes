{
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    # ./bash.nix
    ./git.nix
    ./tmux.nix
  ];

  # programs.bat.enable = true;
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  home.packages = with pkgs; [
    bc
    jq
    mdcat

    ripgrep
    fd
    sd

    zip
    unzip
    claude-code
    rclone
  ];
}
