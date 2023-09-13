{ config, lib, pkgs, ... }: {
  programs.wofi = {
    enable = true;

    settings = {
      lines = 8;
      insensitive = true;
      location = "center";
      prompt = "Search..";
      width = "20%";
    };
  };
}
