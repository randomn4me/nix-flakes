{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.mpd-music;
in
{
  options.custom.mpd-music = {
    enable = mkEnableOption "Enable mpd and ncmpcpp";
    musicDirectory = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/usr/music";
      description = "Directory where your music is stored.";
    };
  };

  config =
    let
      mpd-config = config.services.mpd;
    in
    mkIf cfg.enable {
      services.mpd = {
        enable = true;
        network.startWhenNeeded = true;
        musicDirectory = cfg.musicDirectory;
      };

      services.mpd-mpris.enable = true;

      home.packages = [ pkgs.mpc-cli ];

      programs = {
        ncmpcpp = {
          enable = true;

          settings = {
            ncmpcpp_directory = "~/.config/ncmpcpp";

            mpd_host = mpd-config.network.listenAddress;
            mpd_port = mpd-config.network.port;

            visualizer_data_source = "localhost:5555";
            visualizer_output_name = "my_fifo";
            visualizer_in_stereo = "yes";
            visualizer_type = "wave"; # (spectrum/wave/ellipse);
            visualizer_look = "●▮";

            song_list_format = "{$8%a $4- }{$4%t} $R$3[{%l}]$9";
            song_status_format = "$8%a $4- %t $3- %b$8";

            # colors
            colors_enabled = "yes";
            statusbar_color = "white";
            main_window_color = "white";

            header_visibility = "yes";
            statusbar_visibility = "yes";
            now_playing_prefix = "$8> ";
            now_playing_suffix = "$8 <";
            autocenter_mode = "yes";
            centered_cursor = "yes";
            progressbar_color = "black";
            progressbar_elapsed_color = "yellow";
            # progressbar_look = "●●";
            # progressbar_look = "◾◽";
            # progressbar_look = ".. ";
            # progressbar_look = "▒▓░";
            progressbar_look = "=> ";
            titles_visibility = "yes";
            mouse_support = "no";
            discard_colors_if_item_is_selected = "yes";
            user_interface = "classic";
            playlist_display_mode = "classic";
            follow_now_playing_lyrics = "yes";
            fetch_lyrics_for_current_song_in_background = "yes";
            ignore_leading_the = "yes";
          };

          bindings = [
            {
              key = "=";
              command = "show_clock";
            }
            {
              key = "+";
              command = "volume_up";
            }

            {
              key = "h";
              command = "previous_column";
            }
            {
              key = "l";
              command = "next_column";
            }

            {
              key = "j";
              command = "scroll_down";
            }
            {
              key = "k";
              command = "scroll_up";
            }

            {
              key = ".";
              command = "show_lyrics";
            }
            {
              key = "t";
              command = "select_item";
            }

            {
              key = "d";
              command = "delete_playlist_items";
            }
            {
              key = "d";
              command = "delete_browser_items";
            }
            {
              key = "d";
              command = "delete_stored_playlist";
            }
          ];
        };
      };

    };
}
