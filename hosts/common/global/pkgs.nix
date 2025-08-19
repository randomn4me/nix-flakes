{ pkgs, inputs, ... }:
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
    libgcc

    # chrome usb permissions (eg zmk)
    # uucp
  ];
}
