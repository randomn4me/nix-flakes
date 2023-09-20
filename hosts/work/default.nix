{ pkgs, lib, user, ... }:

{
  imports =  [
    ./hardware-configuration.nix
    ../../modules/desktop/hyprland
    ../common/auto-cpufreq
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    plymouth.enable = true;
  };

  networking.hostName = "work"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  environment.systemPackages = with pkgs; [
    git
    neovim

    wget
    curl
    openconnect

    brightnessctl
    xdg-utils

    fzf

    powertop

    isync
    neomutt
    msmtp
    vdirsyncer
    khard
    urlview
    pandoc
    w3m
    mdcat

    texlive.combined.scheme-full
    zotero
    poppler_utils
    udiskie

    openjdk19

    jameica
  ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.printing = {
    enable = true;
    drivers = [
      pkgs.cups-kyodialog
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  services.thermald.enable = true;

  services.udisks2.enable = true;

  #services.vdirsyncer = {
  #  enable = true;
  #  jobs = {
  #    audacis = {
  #      enable = true;
  #      forceDiscover = true;

  #      user = "phil";
  #      group = "users";

  #      timerConfig = {
  #        OnBootSec = "5min";
  #        OnUnitActivationSec = "10min";
  #      };

  #      config = {
  #        pairs = {
  #          audacis_contacts = {
  #            a = "audacis_contacts_local";
  #            b = "audacis_contacts_remote";
  #            collections = [ "from a" "from b" ];
  #            conflict_resolution = "b wins";
  #            metadata = [ "displayname" ];

  #          };
  #        };
  #        storages = {
  #          audacis_contacts_local = {
  #            type = "filesystem";
  #            path = "~/var/vdirsyncer/audacis_contacts/";
  #            fileext = ".vcf";
  #          };

  #          audacis_contacts_remote = {
  #            type = "carddav";
  #            url = "https://cloud.audacis.net/remote.php/dav/";
  #            username = "philippkuehn";
  #            password.fetch = ["command" "cat" "/home/phil/usr/misc/cloud.audacis.net"];
  #          };
  #        };
  #      };
  #    };
  #  };
  #};

  powerManagement.powertop.enable = true;

  # virtualisation.virtualbox.host = {
  #   enable = true;
  #   enableExtensionPack = true;
  # };

  system.stateVersion = "23.05"; # Did you read the comment?

}

