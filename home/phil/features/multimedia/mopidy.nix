{ pkgs, config, ... }:
{ 
  home = {
    packages = with pkgs; [
      mpc-cli
    ];
  };

  services = {
    mopidy = {
      enable = true;

      extensionPackages = with pkgs; [
        mopidy-spotify
        mopidy-mpd
        mopidy-mpris
      ];

      extraConfigFiles = [ "/home/phil/var/extraconfigs/mopidy_spotify.conf" ];

      settings = {
        file = {
          media_dirs = [
            "$XDG_MUSIC_DIR|music"
            "~/usr/hoerbuecher|audiobooks"
          ];
        };

      };
    };
  };
}
