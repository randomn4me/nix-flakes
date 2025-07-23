{
  imports = [
    ../common/darwin
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = "pkuehn";
  system.stateVersion = 6;
}
