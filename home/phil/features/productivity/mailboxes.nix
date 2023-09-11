{ config, pkgs, lib, ... }:
{ pkgs, lib, config, ... }:

let
  mbsync = "${config.programs.mbsync.package}/bin/mbsync";
  rbw = "${config.programs.rbw.package}/bin/rbw";

  common = rec {
    realName = "Philipp Kühn";
  };
in
{
  accounts.email = {
    maildirBasePath = "Mail";
    accounts = {
      personal = rec {
        primary = true;
        address = "philipp@audacis.net";
        passwordCommand = "${rbw} webmail.your-server.de ${address}";

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

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;

  systemd.user.services.mbsync = {
    Unit = { Description = "mbsync synchronization"; };
    Service =
      let gpgCmds = import ../cli/gpg-commands.nix { inherit pkgs; };
      in
      {
        Type = "oneshot";
        ExecCondition = ''
          /bin/sh -c "${gpgCmds.isUnlocked}"
        '';
        ExecStart = "${mbsync} -a";
      };
  };
  systemd.user.timers.mbsync = {
    Unit = { Description = "Automatic mbsync synchronization"; };
    Timer = {
      OnBootSec = "30";
      OnUnitActiveSec = "5m";
    };
    Install = { WantedBy = [ "timers.target" ]; };
  };
}
