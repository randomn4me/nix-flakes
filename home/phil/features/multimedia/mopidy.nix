{ pkgs, config, ... }: {
  home = { packages = with pkgs; [ mpc-cli ]; };

  services = {
    mopidy = {
      enable = true;

      extensionPackages = with pkgs; [
        mopidy-mpd
        mopidy-mpris
        #mopidy-spotify # TODO mopidy-spotify currently not working
      ];

      #extraConfigFiles = [ "${config.home.homeDirectory}/var/extraconfigs/mopidy_spotify.conf" ];

      settings = {
        file = {
          media_dirs = [
            "$XDG_MUSIC_DIR|music"
            "${config.home.homeDirectory}/usr/hoerbuecher|audiobooks"
          ];
        };

      };
    };
  };
}
