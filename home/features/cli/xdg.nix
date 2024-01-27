{ config, ... }:
{
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "${config.home.homeDirectory}/tmp";
      documents = "${config.home.homeDirectory}/usr/docs";
      download = "${config.home.homeDirectory}/tmp";
      music = "${config.home.homeDirectory}/usr/music";
      pictures = "${config.home.homeDirectory}/usr/pics";
      publicShare = "${config.home.homeDirectory}/var/share";
      templates = "${config.home.homeDirectory}/var/templates";
      videos = "${config.home.homeDirectory}/usr/vids";
    };
  };
}
