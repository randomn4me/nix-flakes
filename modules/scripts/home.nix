{ config, lib, pkgs, host, ... }:

{
  home.file."bin/standalone" = {
    source = ./bin;
    recursive = true;
    force = true;
  };
}

