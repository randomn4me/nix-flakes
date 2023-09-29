{ config, pkgs, ... }:
let
  cat = "${pkgs.coreutils}/bin/cat";
  home = config.home.homeDirectory;


  common = {
    realName = "Philipp Kühn";

    mbsync = let host = "mail.your-server.de"; in {
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
      msmtp = {
        enable = true;
        create = "both";
        expunge = "both";
      };

      folders = {
        inbox = "Inbox";
        drafts = "Drafts";
        sent = "Sent";
        trash = "Trash";
      };

      signature.showSignature = "append";

      neomutt = {
        enable = true;
        extraMailboxes = [ "Archive" "Drafts" "Sent" "Trash" ];
      };

      thunderbird = {
        enable = true;
        profiles = [ config.home.username ];
      };
    };
  };
in
  {
    accounts.email = {
      maildirBasePath = "${home}/var/mail";

      accounts = {
        audacis = rec {
          primary = true;
          address = "philipp@audacis.net";
          userName = address;
          passwordCommand = "${cat} ${home}/usr/misc/mail.audacis.net";

          signature.text = ''
          Hi

          --

          Philipp Kühn
          ${address}

          https://email.is-not-s.ms/
          '';

          neomutt.extraConfig = ''
          color indicator    #${config.colorscheme.colors.base0A}  black
          color status       #${config.colorscheme.colors.base0A}  default
          macro index e      ":set confirmappend=no delete=yes auto_tag=yes\n<save-message>+Archive\n<sync-mailbox>:set confirmappend=yes delete=yes\n"
          '';
        } // common;

        personalvorstand = rec {
          address = "personalvorstand@unikita-darmstadt.de";
          userName = address;
          passwordCommand = "${cat} ${home}/usr/misc/personalvorstand";

          signature.text = ''
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

          neomutt.extraConfig = ''
          color indicator    #${config.colorscheme.colors.base0B}  black
          color status       #${config.colorscheme.colors.base0B}  default
          macro index e      ":set confirmappend=no delete=yes auto_tag=yes\n<save-message>+Archive\n<sync-mailbox>:set confirmappend=yes delete=yes\n"
          '';
        } // common;
      };
    };

    programs.msmtp.enable = true;
    programs.mbsync.enable = true;

    services.mbsync = {
      enable = true;
    };
  }
