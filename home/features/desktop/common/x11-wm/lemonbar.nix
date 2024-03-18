{ pkgs, config, ... }:
let
  xrandr = "${pkgs.xorg.xrandr}/bin/xrandr";

  grep = "${pkgs.gnugrep}/bin/grep";

  date = "${pkgs.coreutils}/bin/date";
  test = "${pkgs.coreutils}/bin/test";
  printf = "${pkgs.coreutils}/bin/printf";
  echo = "${pkgs.coreutils}/bin/echo";
  wc = "${pkgs.coreutils}/bin/wc";

  find = "${pkgs.findutils}/bin/find";

  lemonbar = "${pkgs.lemonbar-xft}/bin/lemonbar";

  sed = "${pkgs.gnused}/bin/sed";

  bat = "${config.home.homeDirectory}/.nix-profile/bin/bat";
  vpn = "${config.home.homeDirectory}/.nix-profile/bin/vpn";

  inherit (config.colorscheme) colors;

  lemonbar-config = ''
    -d \
        -f "Share Tech Mono:size=12" \
        -B "#${colors.base01}" \
        -F "#${colors.base05}" \
        -n "bar"'';

  bar = pkgs.writeShellScriptBin "bar" ''
    MONWIDTH=`${xrandr} | ${grep} primary | ${sed} -n 's/.* \([0-9]\+\)x\([0-9]\+\).*/\1/p'`

    curtime() {
      ${date} "+%d.%m  %H:%M"
    }

    batstat() {
      ${test} "$(${bat} -s)" = "Charging" && ${echo} + || ${echo} ' '
    }

    vpnstatus() {
      ${test} $(${vpn}) = "1" && ${echo} +
    }

    newmails() {
      count=$(${find} ${config.home.homeDirectory}/var/mail/*/Inbox/new -type f | ${wc} -l)
      ${test} $count -gt 0 && ${echo} $count || ${echo} '-'
    }

    # left bar
    while :; do
      ${printf} "%s%3s %3d%s %1s %1s\n" "%{c}" "$(vol)" "$(bat)" "$(batstat)" "$(newmails)" "$(vpnstatus)"
      sleep 1s
    done | ${lemonbar} -g "150x20+0" ${lemonbar-config} &

    # right bar
    while :; do
      ${printf} "%s%s\n" "%{c}" "$(curtime)"
      sleep 5s
    done | ${lemonbar} -g "150x20+$((MONWIDTH - 150))" ${lemonbar-config} &
  '';
in
{
  home.packages = [
    pkgs.lemonbar-xft

    bar
  ];
}
