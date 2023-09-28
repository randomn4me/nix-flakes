{ config, pkgs, lib, ... }:
let
  khard = "${pkgs.khard}/bin/khard";
in
{
  programs.neomutt = {
    enable = true;
    vimKeys = true;
    checkStatsInterval = 60;
    sidebar = {
      enable = true;
      width = 30;
    };
    settings = {
      mark_old = "no";
      text_flowed = "yes";
      reverse_name = "yes";
      query_command = ''"${khard} email --parsable '%s'"'';
    };

    binds = [
      # sidebar
      {
        action = "sidebar-prev";
        key = "K";
        map = [ "index" "pager" ];
      }
      {
        action = "sidebar-next";
        key = "J";
        map = [ "index" "pager" ];
      }
      {
        action = "sidebar-open";
        key = "L";
        map = [ "index" "pager" ];
      }

      # index
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
        action = "top";
        key = "gg";
        map = [ "index" ];
      }
      {
        action = "bottom";
        key = "G";
        map = [ "index" ];
      }
      {
        action = "exit";
        key = "q";
        map = [ "index" ];
      }

      {
        action = "group-reply";
        key = "R";
        map = [ "index" "pager" ];
      }
      {
        action = "search-opposite";
        key = "N";
        map = [ "index" "pager" ];
      }
      {
        action = "noop";
        key = "d";
        map = [ "index" "pager" ];
      }
      {
        action = "delete-message";
        key = "dd";
        map = [ "index" "pager" ];
      }

      {
        action = "complete-query";
        key = "<Tab>";
        map = [ "editor" ];
      }
      #{
      #  action = "complete";
      #  key = "^T";
      #  map = [ "editor" ];
      #}
    ];

    macros = [
      {
        action = "<pipe-message>khard add-email<return>";
        key = "A";
        map = [ "index" ];
      }
    ];

    changeFolderWhenSourcingAccount = true;

    settings = {
      date_format    = "%F, %T";
      index_format   = "%S [%{%m-%d}]  %-15.15F  %s";
      compose_format = "%>-(~size: %l, Atts: %a)-";
      status_format  = "-%?V?(Limit: %V)?-%>-(%P)-";
      attach_format  = "%I %t%2n %T%.40d%> [%.15m/%.10M, %?C?%C, ?%s]";
      pager_format   = "-(%C/%m)-%>-(%P)";
      sidebar_format = " %D%* %?N?%N/?%S";
      forward_format = "Fwd: %s";
    };
  };

  xdg = {
    desktopEntries = {
      neomutt = {
        name = "Neomutt";
        genericName = "Email Client";
        comment = "Read and send emails";
        exec = "neomutt %U";
        icon = "mutt";
        terminal = true;
        categories = [ "Network" "Email" "ConsoleOnly" ];
        type = "Application";
        mimeType = [ "x-scheme-handler/mailto" ];
      };
    };
    mimeApps.defaultApplications = {
      "x-scheme-handler/mailto" = "neomutt.desktop";
    };
  };

}
