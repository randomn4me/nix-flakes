{ pkgs, ... }:
{
  programs.rbw = {
    enable = true;
    settings = {
      email = "p.services@audacis.net";
      base_url = "https://vault.audacis.net";
      pinentry = pkgs.pinentry-qt;
    };
  };
}
