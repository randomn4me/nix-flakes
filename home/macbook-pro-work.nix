{
  ...
}:
{
  imports = [
    ./features/accounts/private
    ./features/accounts/peasec
  ];
  home.username = "pkuehn";
  home.homeDirectory = "/Users/pkuehn";

  # Work machine, so the university account is the primary one. Without this
  # home-manager's "exactly one primary mail account" assertion fails.
  accounts.email.accounts.peasec.primary = true;
  accounts.calendar.accounts.peasec.primary = true;

  programs.home-manager.enable = true;
  home.stateVersion = "25.05";
}
