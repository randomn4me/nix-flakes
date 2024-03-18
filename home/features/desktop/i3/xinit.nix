{ pkgs, ... }:
let
  startx = "${pkgs.xorg.xinit}/bin/startx";
  script_content = ''
    if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
      eval $(dbus-launch --exit-with-session --sh-syntax)
    fi
    systemctl --user import-environment DISPLAY XAUTHORITY

    if command -v dbus-update-activation-environment >/dev/null 2>&1; then
      dbus-update-activation-environment DISPLAY XAUTHORITY
    fi

    exec ${startx} &> /dev/null
  '';
in
{
  home.file.".xinitrc".text = ''
    exec i3
  '';
  programs = {
    fish.loginShellInit = ''
      if test (tty) = "/dev/tty1"
        ${script_content}
      end
    '';
    zsh.loginExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        ${script_content}
      fi
    '';
    bash.profileExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        ${script_content}
      fi
    '';
  };
}
