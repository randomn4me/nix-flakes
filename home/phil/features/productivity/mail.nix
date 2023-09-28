{ config, pkgs, lib, ... }:
let
  mbsync = "${config.programs.mbsync.package}/bin/mbsync";
  cat = "${pkgs.coreutils}/bin/cat";
  home = config.home.homeDirectory;


  common = rec {
    realName = "Philipp Kühn";
  };
in
{
  accounts.email = {
    maildirBasePath = "${home}/var/mail";

    accounts = {
      personal = rec {
        primary = true;
        address = "philipp@audacis.net";
        passwordCommand = "${cat} ${home}/usr/misc/mail.audacis.net";

        imap.host = "mail.your-server.de";
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
        };
        folders = {
          inbox = "Inbox";
          drafts = "Drafts";
          sent = "Sent";
          trash = "Trash";
        };
        neomutt = {
          enable = true;
          extraMailboxes = [ "Archive" "Drafts" "Junk" "Sent" "Trash" ];
        };

        msmtp.enable = true;
        smtp.host = "mail.your-server.de";
        userName = address;
      } // common;

      # college = rec {
      #   address = "g.fontes@usp.br";
      #   passwordCommand = "${pass} ${smtp.host}/${address}";

      #   msmtp.enable = true;
      #   smtp.host = "smtp.gmail.com";
      #   userName = address;
      # } // common;

      # zoocha = rec {
      #   address = "gabriel@zoocha.com";
      #   passwordCommand = "${pass} ${smtp.host}/${address}";

      #   /* TODO: add imap (conditionally)
      #   imap.host = "imap.gmail.com";
      #   mbsync = {
      #     enable = true;
      #     create = "maildir";
      #     expunge = "both";
      #   };
      #   folders = {
      #     inbox = "INBOX";
      #     trash = "Trash";
      #   };
      #   neomutt = {
      #     enable = true;
      #   };
      #   */

      #   msmtp.enable = true;
      #   smtp.host = "smtp.gmail.com";
      #   userName = address;
      # } // common;
    };
  };

  programs.msmtp.enable = true;
  programs.mbsync.enable = true;

  #services.mbsync = {
  #  enable = true;
  #};
}
