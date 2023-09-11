{ pkgs, lib, ... }:
{
  programs.tmux = {
    enable = true;

    clock24 = true;
    extraConfig = ''
      # https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
      # set -ag terminal-overrides ",$TERM:RGB"
      set -g default-terminal "tmux-256color"
      set -sg terminal-overrides ",*:RGB"
    '';
  };
}
