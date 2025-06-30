{
  pkgs,
  config,
  inputs,
  home-manager,
  ...
}:

let
  username = "pkuehn";
in
{
  imports = [
  ];
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  environment = {
    systemPackages = with pkgs; [
      neovim
      git
      mas
      just
    ];
  };

  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.lix;
    gc = {
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [
        "root"
        "pkuehn"
      ];
    };
    linux-builder.enable = true;
  };

  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnfree = true;
    };
    hostPlatform = "aarch64-darwin";
  };

  system.build.applications = pkgs.lib.mkForce (
    pkgs.buildEnv {
      name = "applications";
      paths = config.environment.systemPackages ++ config.home-manager.users.pkuehn.home.packages;
      pathsToLink = "/Applications";
    }
  );

  security.pam.enableSudoTouchIdAuth = true;

  system.stateVersion = 5;

}
