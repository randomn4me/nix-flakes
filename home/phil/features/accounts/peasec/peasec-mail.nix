{ config, pkgs, ... }:
let
  cat = "${pkgs.coreutils}/bin/cat";
  home = config.home.homeDirectory;
in
{
  accounts.email = rec {
    maildirBasePath = "${home}/var/mail";

    accounts = {
      peasec = {
        realName = "Philipp Kühn";
        address = "kuehn@peasec.tu-darmstadt.de";
        userName = "ba01viny";
        passwordCommand = "${cat} ${home}/usr/misc/ba01viny";

        imap = {
          host = "mail.tu-darmstadt.de";
          tls.certificatesFile = "${home}/usr/misc/t-telesec_globalroot_class_2.pem";
        };

        smtp = {
          host = "smtp.tu-darmstadt.de";
          port = 465;
        };

        folders = {
          inbox = "Inbox";
          drafts = "Entw&APw-rfe";
          sent = "Gesendete Elemente";
          trash = "Gel&APY-schte Elemente";
        };


        signature = {
          showSignature = "append";
          text = ''
          --
          Philipp Kühn, M.Sc., TU Darmstadt, Informatik,
          Wissenschaft und Technik für Frieden und Sicherheit (PEASEC),
          Pankratiusstraße 2, 64289 Darmstadt, Raum S220 | 115,
          kuehn@peasec.tu-darmstadt.de, www.peasec.de

          My working hours may not be your working hours.
          Please do not feel obligated to reply outside of your normal work schedule.
          '';
        };

        #mbsync = {
        #  enable = true;
        #  create = "both";
        #  expunge = "both";
        #};

        #thunderbird = {
        #  enable = true;
        #  profiles = [ config.home.username ];
        #};


        #neomutt = {
        #  enable = true;
        #  extraMailboxes = [ "Archiv" "Entw&APw-rfe" "Gesendete Elemente" "Junk-E-Mail" "Gel&APY-schte Elemente" ];
        #  extraConfig = let inherit (config.colorscheme) colors; in ''
        #  color indicator    #${colors.base0F}  black
        #  color status       #${colors.base0F}  default

        #  color sidebar_highlight #${colors.base0F} default

        #  named-mailboxes "peasec"    "+Inbox"
        #  named-mailboxes " archive"  "+Archiv"
        #  named-mailboxes " sent"     "+Gesendete Elemente"
        #  named-mailboxes " drafts"   "+Entw&APw-rfe"
        #  named-mailboxes " junk"     "+Junk-E-Mail"
        #  named-mailboxes " trash"    "+Gel&APY-schte Elemente"

        #  macro index e      ":set confirmappend=no delete=yes auto_tag=yes\n<save-message>+Archive\n<sync-mailbox>:set confirmappend=yes delete=yes\n"
        #  '';
        #};
      };
    };
  };

  programs.msmtp.enable = true;
  programs.mbsync.enable = true;

  services.mbsync = {
    enable = true;
  };
}
