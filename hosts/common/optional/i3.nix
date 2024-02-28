{ pkgs, ... }:
{
    services.xserver = {
        enable = true;

        windowManager.i3 = {
            enable = true;
            extraPackages = with pkgs; [
              dmenu
              i3status-rust
              i3lock
            ];
        };
    };
}
