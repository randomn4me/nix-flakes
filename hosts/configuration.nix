{ config, lib, pkgs, inputs, user, ... }:

{
  imports =
    (import ../modules/editors) ++
    (import ../modules/shell);

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
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
      ripgrep
      killall
      neovim
      wget
      git
      udiskie
    ];

    sessionVariables = rec {
      XDG_CACHE_HOME  = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME   = "$HOME/.local/share";
      XDG_STATE_HOME  = "$HOME/.local/state";

      XDG_BIN_HOME    = "$HOME/.local/bin";
      PATH = [ 
        "${XDG_BIN_HOME}"
      ];
    };

  };

  services = {
    # audio
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
      options = "--delete-older-than 2d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "23.05";

}
