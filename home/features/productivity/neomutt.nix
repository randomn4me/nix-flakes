{
  pkgs,
  config,
  lib,
  ...
}:
let
  mkdir = "${pkgs.coreutils}/bin/mkdir";
  cp = "${pkgs.coreutils}/bin/cp";
  rm = "${pkgs.coreutils}/bin/rm";

  w3m = "${pkgs.w3m}/bin/w3m";

  khard = "${pkgs.khard}/bin/khard";
  khal = "${pkgs.khal}/bin/khal";

  terminal = config.home.sessionVariables.TERMINAL;
  neomutt = "${pkgs.neomutt}/bin/neomutt";

  xdg-open = "${pkgs.xdg-utils}/bin/xdg-open";

  home = "${config.home.homeDirectory}";
in
{

  home.packages = with pkgs; [ mailcap ];

  xdg.configFile."neomutt/mailcap".text = ''
    text/html; ${w3m} -I %{charset} -T text/html; copiousoutput;
    text/calendar; ${khal} import %s;

    image/*; ${mkdir} -p /tmp/mutt \; ${cp} %s /tmp/mutt \; ${xdg-open} /tmp/mutt/$(basename %s); ${rm} /tmp/mutt/%s;

    application/*; ${xdg-open} %s &> /dev/null &;
  '';

  programs.neomutt = {
    enable = true;
    checkStatsInterval = 60;

    sidebar = {
      enable = true;
      width = 20;
      format = "%D%* %?N?%N/?%S";
    };

    settings = {
      color_directcolor = "yes";

      sidebar_sort_method = "path";
      sidebar_folder_indent = "yes";
      sidebar_indent_string = " ";

      menu_scroll = "yes";

      pager_stop = "yes";
      markers = "no";

      sort_aux = "reverse-last-date-received";
      query_command = ''"${khard} email --parsable '%s'"'';

      forward_quote = "yes";
      fast_reply = "yes";

      sig_dashes = "no";
      sig_on_top = "yes";

      postpone = "ask-yes";

      sendmail_wait = "-1";

      abort_noattach = "ask-yes";
      abort_noattach_regex = ''"\\<(anhängen|angehängt|anhang|anhänge|hängt an|anbei|attach|attached|attachments|append)\\>"'';

      mailcap_path = "${home}/.config/neomutt/mailcap";
      edit_headers = "yes";

      date_format = ''"%F, %T"'';
      index_format = ''"%S [%{%m-%d}]  %-15.15F  %s"'';
      compose_format = ''"%>-(~size: %l, Atts: %a)-"'';
      status_format = ''"-%?V?(Limit: %V)?-%>-(%P)-"'';
      attach_format = ''"%I %t%2n %T%.40d%> [%.15m/%.10M, %?C?%C, ?%s]"'';
      pager_format = ''"-(%C/%m)-%>-(%P)"'';
      forward_format = ''"Fwd: %s"'';
    };

    binds =
      [
        # sidebar
        {
          action = "sidebar-prev";
          key = "K";
          map = [
            "index"
            "pager"
          ];
        }
        {
          action = "sidebar-next";
          key = "J";
          map = [
            "index"
            "pager"
          ];
        }
        {
          action = "sidebar-open";
          key = "L";
          map = [
            "index"
            "pager"
          ];
        }

        # index
        {
          action = "sync-mailbox";
          key = "<space>";
          map = [ "index" ];
        }
        {
          action = "noop";
          key = "x";
          map = [ "index" ];
        }
        {
          action = "noop";
          key = "g";
          map = [ "index" ];
        }
        {
          action = "first-entry";
          key = "gg";
          map = [ "index" ];
        }
        {
          action = "last-entry";
          key = "G";
          map = [ "index" ];
        }
        {
          action = "collapse-thread";
          key = "-";
          map = [ "index" ];
        }

        # pager
        {
          action = "next-line";
          key = "j";
          map = [ "pager" ];
        }
        {
          action = "previous-line";
          key = "k";
          map = [ "pager" ];
        }
        {
          action = "noop";
          key = "g";
          map = [ "pager" ];
        }
        {
          action = "top";
          key = "gg";
          map = [ "pager" ];
        }
        {
          action = "bottom";
          key = "G";
          map = [ "pager" ];
        }
        {
          action = "exit";
          key = "q";
          map = [ "pager" ];
        }

        # index and pager
        {
          action = "group-reply";
          key = "R";
          map = [
            "index"
            "pager"
          ];
        }
        {
          action = "search-opposite";
          key = "N";
          map = [
            "index"
            "pager"
          ];
        }
        {
          action = "noop";
          key = "d";
          map = [
            "index"
            "pager"
          ];
        }
        {
          action = "delete-message";
          key = "dd";
          map = [
            "index"
            "pager"
          ];
        }

        # editor
        {
          action = "complete-query";
          key = "<Tab>";
          map = [ "editor" ];
        }
      ]
      ++ map (key: {
        action = "noop";
        key = toString key;
        map = [ "index" ];
      }) (lib.range 0 9);

    macros = [
      {
        action = "<enter-command>source ~/.config/neomutt/audacis<enter><change-folder>!<enter>";
        key = "2";
        map = [
          "index"
          "pager"
        ];
      }
      {
        action = "<enter-command>source ~/.config/neomutt/peasec<enter><change-folder>!<enter>";
        key = "3";
        map = [
          "index"
          "pager"
        ];
      }
      {
        action = "<enter-command>source ~/.config/neomutt/sink<enter><change-folder>!<enter>";
        key = "4";
        map = [
          "index"
          "pager"
        ];
      }

      {
        action = "<pipe-message>khard add-email<return>";
        key = "A";
        map = [ "index" ];
      }
      {
        action = "<save-entry><kill-line>~/tmp/";
        key = "S";
        map = [ "attach" ];
      }
      {
        action =
          let
            mbsync = "${config.programs.mbsync.package}/bin/mbsync";
          in
          "<enter-command>unset wait_key<enter><shell-escape>${mbsync} -a<enter>";
        key = "<f12>";
        map = [
          "index"
          "pager"
        ];
      }
      {
        action =
          let
            urlscan = "${pkgs.urlscan}/bin/urlscan";
          in
          "<pipe-message> ${urlscan}<enter>";
        key = "b";
        map = [ "pager" ];
      }
    ];

    changeFolderWhenSourcingAccount = true;
    unmailboxes = true;

    extraConfig =
      let
        inherit (config.colorscheme) colors;
      in
      ''
        color normal       #${colors.base05}   default
        color error        #${colors.base0F}   default
        color tilde        #${colors.base0D}   default
        color message      #${colors.base05}   default
        color markers      #${colors.base0A}   default
        color attachment   #${colors.base0A}   default
        color search       #${colors.base05}   default
        color status       #${colors.base09}   default
        color indicator    #${colors.base09}   black
        color tree         #${colors.base05}   default


        color hdrdefault   #${colors.base0F}   default


        color index        #${colors.base0F}   default    "~D"
        color index        #${colors.base0A}   default    "~F"
        color index        #${colors.base0B}   default    "~N"


        color quoted       #${colors.base09}   default
        color signature    #${colors.base0A}   default


        color body         #${colors.base05}   default    "[:;][-o]?[)/(|]"

        color body         #${colors.base0D}   default    "([a-z][a-z0-9+-]*://(((([a-z0-9_.!~*'();:&=+$,-]|%[0-9a-f][0-9a-f])*@)?((([a-z0-9]([a-z0-9-]*[a-z0-9])?)\\.)*([a-z]([a-z0-9-]*[a-z0-9])?)\\.?|[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)(:[0-9]+)?)|([a-z0-9_.!~*'()$,;:@&=+-]|%[0-9a-f][0-9a-f])+)(/([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*(;([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*)*(/([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*(;([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*)*)*)?(\\?([a-z0-9_.!~*'();/?:@&=+$,-]|%[0-9a-f][0-9a-f])*)?(#([a-z0-9_.!~*'();/?:@&=+$,-]|%[0-9a-f][0-9a-f])*)?|(www|ftp)\\.(([a-z0-9]([a-z0-9-]*[a-z0-9])?)\\.)*([a-z]([a-z0-9-]*[a-z0-9])?)\\.?(:[0-9]+)?(/([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*(;([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*)*(/([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*(;([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*)*)*)?(\\?([-a-z0-9_.!~*'();/?:@&=+$,]|%[0-9a-f][0-9a-f])*)?(#([-a-z0-9_.!~*'();/?:@&=+$,]|%[0-9a-f][0-9a-f])*)?)[^].,:;!)? \t\r\n<>\"]"

        color body         #${colors.base0D}   default    "((@(([0-9a-z-]+\\.)*[0-9a-z-]+\\.?|#[0-9]+|\\[[0-9]?[0-9]?[0-9]\\.[0-9]?[0-9]?[0-9]\\.[0-9]?[0-9]?[0-9]\\.[0-9]?[0-9]?[0-9]\\]),)*@(([0-9a-z-]+\\.)*[0-9a-z-]+\\.?|#[0-9]+|\\[[0-9]?[0-9]?[0-9]\\.[0-9]?[0-9]?[0-9]\\.[0-9]?[0-9]?[0-9]\\.[0-9]?[0-9]?[0-9]\\]):)?[0-9a-z_.+%$-]+@(([0-9a-z-]+\\.)*[0-9a-z-]+\\.?|#[0-9]+|\\[[0-2]?[0-9]?[0-9]\\.[0-2]?[0-9]?[0-9]\\.[0-2]?[0-9]?[0-9]\\.[0-2]?[0-9]?[0-9]\\])"
      '';
  };

  xdg = {
    desktopEntries = {
      neomutt = {
        name = "Neomutt";
        genericName = "Email Client";
        comment = "Read and send emails";
        exec = "${terminal} --app-id neomutt ${neomutt} %U";
        icon = "mutt";
        categories = [
          "Network"
          "Email"
          "ConsoleOnly"
        ];
        type = "Application";
        mimeType = [ "x-scheme-handler/mailto" ];
      };
    };
    mimeApps.defaultApplications = {
      "x-scheme-handler/mailto" = "neomutt.desktop";
    };
  };

  programs.bash.shellAliases.mutt = "neomutt";
}
