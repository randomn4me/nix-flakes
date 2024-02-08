{ config, pkgs, lib, ... }:
let
  cat = "${pkgs.coreutils}/bin/cat";
  home = config.home.homeDirectory;

  common = let host = "mail.your-server.de";
  in {
    realName = "Philipp Kühn";

    mbsync = {
      enable = true;
      create = "both";
      expunge = "both";
    };

    imap = {
      host = host;
      port = 143;
      tls.useStartTls = true;
    };

    smtp = {
      host = host;
      port = 587;
      tls.useStartTls = true;
    };

    msmtp.enable = true;

    folders = {
      inbox = "Inbox";
      drafts = "Drafts";
      sent = "Sent";
      trash = "Trash";
    };

    thunderbird = {
      enable = true;
      profiles = [ config.home.username ];
    };
  };
in {
  imports = [ ../mbsync.nix ];

  accounts.email = {
    maildirBasePath = "${home}/var/mail";

    accounts = {
      audacis = rec {
        primary = lib.mkDefault false;
        address = "philipp@audacis.net";
        userName = address;
        passwordCommand = "${cat} ${home}/usr/misc/mail.audacis.net";

        signature = {
          showSignature = "append";
          text = ''
            Hi

            -- 

            Philipp Kühn
            ${address}

            https://email.is-not-s.ms/
          '';
        };

        neomutt = {
          enable = true;
          extraMailboxes = [ "Archive" "Drafts" "Sent" "Trash" ];
          extraConfig = let
            inherit (config.colorscheme) colors;
          in ''
            named-mailboxes "audacis"   "+Inbox"
            named-mailboxes " archive"  "+Archive"
            named-mailboxes " sent"     "+Sent"
            named-mailboxes " drafts"   "+Drafts"
            named-mailboxes " trash"    "+Trash"

            color indicator    #${colors.base0A}  black
            color status       #${colors.base0A}  default

            color sidebar_highlight  #${colors.base0A}  default

            macro index e      ":set confirmappend=no delete=yes auto_tag=yes\n<save-message>+Archive\n<sync-mailbox>:set confirmappend=yes delete=yes\n"
          '';
        };
      } // common;

      personalvorstand = rec {
        address = "personalvorstand@unikita-darmstadt.de";
        userName = address;
        passwordCommand = "${cat} ${home}/usr/misc/personalvorstand";

        signature = {
          showSignature = "append";
          text = ''
            Hi
            Cheers,
            Philipp

            -- 
            Philipp Kühn
            Personalvorstand

            uniKITA Darmstadt e.V.
            El-Lissitzky-Str. 5
            64287 Darmstadt

            personalvorstand@unikita-darmstadt.de
            www.unikita-darmstadt.de

            Meine Arbeitszeiten sind nicht unbedingt deine Arbeitszeiten.
            Bitte fühle dich nicht verpflichtet, außerhalb deiner normalen Arbeitszeiten zu
            antworten.

            Diese Mail enthält vertrauliche und rechtlich geschützte Informationen. Wenn du
            nicht der richtige Adressat bist und diese Mail irrtümlich erhalten hast,
            informieren mich bitte sofort und vernichte diese Mail.

            https://email.is-not-s.ms/
          '';
        };

        neomutt = {
          enable = true;
          extraMailboxes = [ "Archive" "Drafts" "Sent" "Trash" ];
          extraConfig = let
            inherit (config.colorscheme) colors;
          in ''
            named-mailboxes "unikita"   "+Inbox"
            named-mailboxes " archive"  "+Archive"
            named-mailboxes " sent"     "+Sent"
            named-mailboxes " drafts"   "+Drafts"
            named-mailboxes " trash"    "+Trash"

            color indicator    #${colors.base0B}  black
            color status       #${colors.base0B}  default

            color sidebar_highlight  #${colors.base0B}  default

            macro index e      ":set confirmappend=no delete=yes auto_tag=yes\n<save-message>+Archive\n<sync-mailbox>:set confirmappend=yes delete=yes\n"
          '';
        };
      } // common;

      sink = rec {
        address = "sink@audacis.net";
        userName = address;
        passwordCommand = "${cat} ${home}/usr/misc/sink.audacis.net";

        neomutt = {
          enable = true;
          extraMailboxes = [ "Archive" "Drafts" "Sent" "Trash" ];
          extraConfig = let
            inherit (config.colorscheme) colors;
          in ''
            named-mailboxes "sink"   "+Inbox"
            named-mailboxes " archive"  "+Archive"
            named-mailboxes " sent"     "+Sent"
            named-mailboxes " drafts"   "+Drafts"
            named-mailboxes " trash"    "+Trash"

            color indicator    #${colors.base0D}  black
            color status       #${colors.base0D}  default

            color sidebar_highlight  #${colors.base0D}  default

            macro index e      ":set confirmappend=no delete=yes auto_tag=yes\n<save-message>+Archive\n<sync-mailbox>:set confirmappend=yes delete=yes\n"
          '';
        };
      } // common;
    };
  };
}
