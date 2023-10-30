{ pkgs, ... }:
let
  startx = "${pkgs.xorg.xinit}/bin/startx";
in {
  home.file.".xinitrc".text = ''
    exec cwm
  '';
  programs = {
    fish.loginShellInit = ''
      if test (tty) = "/dev/tty1"
        exec ${startx} &> /dev/null
      end
    '';
    zsh.loginExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec ${startx} &> /dev/null
      fi
    '';
    bash.profileExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec ${startx} &> /dev/null
      fi
    '';
  };
}
