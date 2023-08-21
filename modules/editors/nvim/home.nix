{ config, lib, pkgs, unstable, host, ... }:

{
  xdg.configFile.nvim.source = ./nvim;
}
