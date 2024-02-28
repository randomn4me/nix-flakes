{ config, pkgs, ... }:
let
  inherit (config.colorscheme) colors;

  dmenu = "${pkgs.dmenu}/bin/dmenu";

  loginctl = "${pkgs.systemd}/bin/loginctl";
  systemctl = "${pkgs.systemd}/bin/systemctl";

  printf = "${pkgs.coreutils}/bin/printf";

  menu-config = '' -fn "Share Tech Mono Proto 12" -i \
    -nb "#000000" \
    -nf "#${colors.base05}" \
    -sb "#${colors.base05}" \
    -sf "#000000"'';

  menu-run = pkgs.writeShellScriptBin "menu-run" ''
    ${dmenu}_run ${menu-config}
  '';

  shutdown-menu = pkgs.writeShellScriptBin "shutdown-menu" ''
    res=$(${printf} "logout\nreboot\nsuspend\nshutdown" | ${dmenu} ${menu-config})

    case "$res" in
    "logout")   ${loginctl} terminate-user ${config.home.username} ;;
    "reboot")   ${systemctl} reboot ;;
    "suspend")  ${systemctl} suspend ;;
    "shutdown") ${systemctl} poweroff ;;
    esac

    exit 0
  '';
in {
  home.packages = [
    pkgs.dmenu

    menu-run
    shutdown-menu
  ];
}
