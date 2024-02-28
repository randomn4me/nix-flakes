{ pkgs, ... }:
{
  home.packages = with pkgs; [ iamb ];

  xdg.configFile."iamb/config.json".text = /* json */ ''
  {
    "profiles": {
      "private": {
        "url": "https://matrix.org",
        "user_id": "@r4ndomname:matrix.org"
      },
        "work": {
          "url": "https://matrix.tu-darmstadt.de",
          "user_id": "@ba01viny:matrix.tu-darmstadt.de"
        }
    },
    "default_profile": "private",
    "layout": { "style": "restore" },
    "settings": {
      "username_display": "localpart"
    }
  }
  '';
}
