{
  config,
  pkgs,
  lib,
  ...
}:
let
  cat = "${pkgs.coreutils}/bin/cat";
  home = config.home.homeDirectory;

  common =
    let
      host = "mail.your-server.de";
    in
    {
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
  msmtp_command = "msmtp";
in
{
  imports = [
    ../mbsync.nix
    ../signature-strings.nix
  ];

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
          extraMailboxes = [
            "Archive"
            "Drafts"
            "Sent"
            "spambucket"
            "Trash"
          ];
          sendMailCommand = "${msmtp_command} -a audacis";
          extraConfig =
            let
              inherit (config.colorscheme) colors;
            in
            ''
              named-mailboxes "audacis"   "+Inbox"
              named-mailboxes " archive"  "+Archive"
              named-mailboxes " sent"     "+Sent"
              named-mailboxes " drafts"   "+Drafts"
              named-mailboxes " junk"     "+spambucket"
              named-mailboxes " trash"    "+Trash"

              color indicator    #${colors.base0A}  black
              color status       #${colors.base0A}  default

              color sidebar_highlight  #${colors.base0A}  default

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
          extraMailboxes = [
            "Archive"
            "Drafts"
            "Sent"
            "spambucket"
            "Trash"
          ];
          sendMailCommand = "${msmtp_command} -a sink";
          extraConfig =
            let
              inherit (config.colorscheme) colors;
            in
            ''
              named-mailboxes "sink"   "+Inbox"
              named-mailboxes " archive"  "+Archive"
              named-mailboxes " sent"     "+Sent"
              named-mailboxes " drafts"   "+Drafts"
              named-mailboxes " junk"     "+spambucket"
              named-mailboxes " trash"    "+Trash"

              color indicator    #${colors.base0E}  black
              color status       #${colors.base0E}  default

              color sidebar_highlight  #${colors.base0E}  default

              macro index e      ":set confirmappend=no delete=yes auto_tag=yes\n<save-message>+Archive\n<sync-mailbox>:set confirmappend=yes delete=yes\n"
            '';
        };
      } // common;
    };
  };
}
