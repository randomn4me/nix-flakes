{ config, lib, pkgs, ... }:

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

      extraConfigFiles = [
        /home/phil/var/extraconfigs/mopidy_spotify.conf
      ];

      settings = {
        file = {
          media_dirs = [
            "$XDG_MUSIC_DIR|music"
            "~/usr/hoerbuecher|audiobooks"
          ];
        };

        audio = {
          output = "tee name=t ! queue ! autoaudiosink t. ! queue ! audio/x-raw,rate=44100,channels=2,format=S16LE ! udpsink host=localhost port=5555";
        };
      };
    };
  };
}

