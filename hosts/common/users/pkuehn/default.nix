{
  pkgs,
  config,
  ...
}:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.users.phil = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ]
    ++ ifTheyExist [
      "networkmanager"
      "i2c"
    ];

    linger = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjYx3VV5aNN1LSG3PZ5Rf209lDJ7Z1MC0RLBbOckvCb pkuehn@macbook"
    ];
  };
}

