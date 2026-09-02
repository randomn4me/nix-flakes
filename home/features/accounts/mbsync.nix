{ lib, pkgs, ... }:
{
  programs.msmtp.enable = true;
  programs.mbsync.enable = true;

  services.mbsync = {
    enable = true;
    frequency = lib.mkDefault "*-*-* *:00/5";

    # Nudge waybar's custom/mail module (RTMIN+8, see
    # ../desktop/common/wayland-wm/waybar.nix) instead of having the bar walk
    # every maildir on a 5s timer. Failure here must not fail the sync.
    postExec = "${pkgs.writeShellScript "waybar-mail-signal" ''
      ${pkgs.procps}/bin/pkill -RTMIN+8 waybar || true
    ''}";
  };
}
