{ pkgs, config, ... }:
{
  home.packages = [ pkgs.lemonbar-xft ];

  home.file.".local/bin/bar".text = let
    xrandr = "${pkgs.xorg.xrandr}/bin/xrandr";
    grep = "${pkgs.coreutils}/bin/grep";
    date = "${pkgs.coreutils}/bin/date";
    sed = "${pkgs.gnused}/bin/sed";

    bat = "${config.home.homeDirectory}/.local/bin/bat";
    vpn = "${config.home.homeDirectory}/.local/bin/vpn";
  in ''
    #!/usr/bin/env bash

    MONWIDTH=`${xrandr} | ${grep} primary | ${sed} -n 's/.* \([0-9]\+\)x\([0-9]\+\).*/\1/p'`

    curtime() {
      ${date} "+%H:%M"
    }

    batstat() {
      test "$(${bat} -s)" = "Charging" && echo + || echo ' '
    }

    vpnstatus() {
      test $(${vpn}) = "1" && echo +
    }

    newmails() {
      mailfolder=~/var/mail
      audacis=$(ls ~/var/mail/audacis/Inbox/new | wc -l)
      personalvorstand=$(ls ~/var/mail/personalvorstand/Inbox/new | wc -l)
      peasec=$(ls ~/var/mail/peasec/Inbox/new | wc -l)
      test $(($audacis + $personalvorstand + $peasec)) -gt 0 && echo 'N' || echo '-'
    }

    # left bar
    while :; do
      printf "%s%3s  %3d%s %1s  %1s\n" "%{c}" "$(vol)" "$(bat)" "$(batstat)" "$(vpnstatus)"
      sleep 1s
    done | mybar 0 "bar" &

    # right bar
    while :; do
      printf "%s%s\n" "%{c}" "$(curtime)"
      sleep 5s
    done | mybar $((MONWIDTH - 150)) "bar" &

  '';
}
