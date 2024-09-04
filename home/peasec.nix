{
  pkgs,
  inputs,
  outputs,
  ...
}:
{
  imports = [
    ./global

    ./features/ssh/private.nix
    ./features/ssh/peasec.nix

    ./features/accounts/private
    ./features/accounts/peasec

    ./features/productivity

    ./features/desktop/sway
    ./features/multimedia
    ./features/backup
    ./features/rbw
    ./features/scripts

    ./features/cli/udiskie.nix

    inputs.nix-index-database.hmModules.nix-index
  ];
  custom.nvim.enable = true;

  accounts.email.accounts.peasec.primary = true;
  accounts.calendar.accounts.peasec.primary = true;

  systemd.user.startServices = "sd-switch";

  home.packages =
    let
      syncall = pkgs.syncall.overrideAttrs (prev: {
        version = "1.8.8";

        src = prev.src.override {
          rev = "v1.8.8";
          hash = "sha256-CTtk7NMmLZ9jZVI1+B/dFEJI2+JVVkV6vwtqmeFjBzk=";
        };

        postPatch = ''
          substituteInPlace pyproject.toml \
          --replace-fail 'loguru = "^0.5.3"' 'loguru = "^0.7"' \
          --replace-fail 'PyYAML = "~5.3.1"' 'PyYAML = "^6.0"' \
          --replace-fail 'bidict = "^0.21.4"' 'bidict = "^0.23"'
        '';

        propagatedBuildInputs = with pkgs.python3.pkgs; prev.propagatedBuildInputs ++ [
          xdg
          google-api-python-client
          google-auth-oauthlib
          setuptools
        ];

        meta = prev.meta // {
          broken = false;
        };
      });
    in
    with pkgs;
    [
      # work
      texlive.combined.scheme-full
      hunspellDicts.de_DE
      hunspellDicts.en_US

      xournalpp
      rclone
      gnumake
      watchexec
      openconnect
      glab
      pandoc
      ffmpeg
      zotero
      syncall

      # home
      ddcutil
      comma
      obsidian
      darktable
      calibre
      tesseract
      ocrmypdf
      makemkv
      mkvtoolnix
      yt-dlp
      devenv
      timewarrior
    ];

  monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      scaling = 1.0;
      primary = true;
    }
  ];

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;

  wallpaper = outputs.wallpapers.hollow-knight-abyss;
  #wallpaper = outputs.wallpapers.aenami-bright-planet;
  #wallpaper = outputs.wallpapers.aenami-15steps;
  #wallpaper = outputs.wallpapers.aenami-far-from-tomorrow;
  #wallpaper = outputs.wallpapers.aenami-cold;
}
