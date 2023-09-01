{ config, lib, pkgs, unstable, inputs, user, ... }:

{
  imports =
    (import ../modules/editors);

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "vboxusers" ];
  };
  security.sudo.wheelNeedsPassword = false;

  time.timeZone = "Europe/Berlin";
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  console = {
    keyMap = "de";
  };

  environment = {
    systemPackages = with pkgs; [
      fd
      sd
      du-dust
      bc
      ripgrep
      killall
      neovim
      wget
      git
      pamixer
      unstable.borgbackup
      udiskie

      gnumake
      zoxide
      tmux
    ];

    variables = {
      EDITOR = "nvim";
    };

    sessionVariables = rec {
      XDG_CACHE_HOME  = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME   = "$HOME/.local/share";
      XDG_STATE_HOME  = "$HOME/.local/state";

      XDG_DESKTOP_DIR     = "$HOME/tmp";
      XDG_DOCUMENTS_DIR   = "$HOME/usr/docs";
      XDG_DOWNLOAD_DIR    = "$HOME/tmp";
      XDG_MUSIC_DIR       = "$HOME/usr/music";
      XDG_PICTURES_DIR    = "$HOME/usr/pics";
      XDG_PUBLICSHARE_DIR = "$HOME/tmp";
      XDG_TEMPLATES_DIR   = "$HOME/tmp";
      XDG_VIDEOS_DIR      = "$HOME/usr/vids";

      XDG_BIN_HOME    = "$HOME/bin";
      PATH = [ 
        "$XDG_BIN_HOME/standalone"
        "$XDG_BIN_HOME/hyprland"
      ];
    };

  };

  fonts.fonts = with pkgs; [
    inconsolata-nerdfont
  ];

  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
	support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };

    # automounting
    udisks2.enable = true;

    # ssh
    openssh.enable = true;

    getty.autologinUser = "${user}";

    flatpak.enable = true;
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "23.05";

}
