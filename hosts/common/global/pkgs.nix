{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    tmux
    file
    coreutils
    btop
    htop
    curl
    wget
    git
    vim
  ];
}
