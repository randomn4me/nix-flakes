{ config, pkgs, ... }: {
  imports = [
    ../common
    ../common/x11-wm

    ./tty-init.nix
  ];

  xsession = {
    enable = true;
    initExtra = let
      hsetroot = "${pkgs.hsetroot}/bin/hsetroot";
    in ''
      ${hsetroot} -fill ${config.wallpaper}
    '';
  };

  home.file.".cwmrc".text = let
    i3lock-color = "${pkgs.i3lock-color}/bin/i3lock-color";
    maim = "${pkgs.maim}/bin/maim";
    date = "${pkgs.coreutils}/bin/date";

    playerctl = "${config.services.playerctld.package}/bin/playerctl";
    rofi = "${config.programs.rofi.package}/bin/rofi";

    inherit (config.colorscheme) colors;
  in ''
    fontname 'Share Tech Mono:pixelsize=11:bold'

    ${if config.programs.alacritty.enable then
      "command alacritty alacritty"
    else
      ""}
    ${if config.programs.firefox.enable then "command firefox firefox" else ""}

    ########################################
    # do not manage these
    ########################################
    ignore lemonbar
    ignore dmenu

    unbind-key all

    ########################################
    # autogroups
    ########################################
    autogroup 1 "Alacritty"

    autogroup 2 "Zathura"

    autogroup 3 "mpv"
    autogroup 3 "Zotero"
    autogroup 3 "libreoffice"

    autogroup 4 "Signal"
    autogroup 4 "neomutt"

    autogroup 5 "firefox"

    autogroup 6 "zoom"

    autogroup 7 "obsidian"

    autogroup 9 "spotify"


    ########################################
    # behavior, look & feel
    ########################################
    borderwidth             3
    color inactiveborder    "#${colors.base03}"
    color activeborder      "#${colors.base09}"
    color menubg            "#${colors.base01}"
    color menufg            "#${colors.base05}"
    color font              "#${colors.base05}"
    color selfont           "#${colors.base01}"
    color urgencyborder     "#${colors.base0A}"
    color urgencyborder     "#${colors.base0A}"

    gap                     25 10 10 10 
    moveamount              20


    ########################################
    # POSITION & SIZE
    ########################################
    bind-key MS-d       window-vmaximize
    bind-key MS-f       window-maximize

    bind-key M-h        window-move-left
    bind-key M-j        window-move-down
    bind-key M-k        window-move-up
    bind-key M-l        window-move-right
    bind-key MS-h       window-move-left-big
    bind-key MS-j       window-move-down-big
    bind-key MS-k       window-move-up-big
    bind-key MS-l       window-move-right-big

    bind-key 4-h        window-resize-left
    bind-key 4-j        window-resize-down
    bind-key 4-k        window-resize-up
    bind-key 4-l        window-resize-right
    bind-key 4S-h       window-resize-left-big
    bind-key 4S-j       window-resize-down-big
    bind-key 4S-k       window-resize-up-big
    bind-key 4S-l       window-resize-right-big

    bind-key MS-t       window-snap-up-left
    bind-key MS-z       window-snap-up-right
    bind-key MS-v       window-snap-down-left
    bind-key MS-b       window-snap-down-right


    ########################################
    # CONTROL
    ########################################
    bind-key MS-Return  window-hide
    bind-key M-q        window-delete
    bind-key M-Tab      window-cycle


    ########################################
    # Group control
    ########################################
    bind-key M-1        group-toggle-1
    bind-key M-2        group-toggle-2
    bind-key M-3        group-toggle-3
    bind-key M-4        group-toggle-4
    bind-key M-5        group-toggle-5
    bind-key M-6        group-toggle-6
    bind-key M-7        group-toggle-7
    bind-key M-8        group-toggle-8
    bind-key M-9        group-toggle-9

    bind-key MS-1       window-movetogroup-1
    bind-key MS-2       window-movetogroup-2
    bind-key MS-3       window-movetogroup-3
    bind-key MS-4       window-movetogroup-4
    bind-key MS-5       window-movetogroup-5
    bind-key MS-6       window-movetogroup-6
    bind-key MS-7       window-movetogroup-7
    bind-key MS-8       window-movetogroup-8
    bind-key MS-9       window-movetogroup-9


    ########################################
    # Custom shortcuts
    ########################################
    bind-key M-Return   alacritty
    bind-key M-m        "alacritty --class 'mutt,mutt' -e neomutt"
    bind-key M-s        "alacritty --class 'spotify,spotify' -e ncmpcpp"

    bind-key CM-l       "${i3lock-color} -i ${config.wallpaper} -F --radius 40 --keylayout 0"
    bind-key CM-s       "${maim} -s ${config.home.homeDirectory}/usr/pics/screencaptures/$(${date} +%F_%Hh%Mm%S).png"

    bind-key M-space    "${rofi} -show drun"
    bind-key MS-q       shutdown-menu
    bind-key M-p        passmenu
    bind-key C-space    "bone toggle"

    bind-key XF86AudioPlay "${playerctl} play-pause"


    ########################################
    # Session management
    ########################################
    bind-key CM-r  restart


    ########################################
    # Mousebindings
    ########################################
    bind-mouse M-1   window-move
    bind-mouse M-3   window-resize
  '';
}
