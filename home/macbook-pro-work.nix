{
  ...
}:
{
  imports = [
    ./features/accounts/private
    ./features/accounts/peasec
  ];
  home.homeDirectory = "/Users/pkuehn";

  programs.home-manager.enable = true;
  home.stateVersion = "25.05";
}
