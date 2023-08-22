{ config, lib, pkgs, unstable, host, ... }:

{
  home.file."bin/standalone" = {
    source = ./bin;
    recursive = true;
  };
}

