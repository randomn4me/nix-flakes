{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ neovim tmux file coreutils btop ];
}
