{
  pkgs,
  config,
  ...
}:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  users.users.milla = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ]
    ++ ifTheyExist [
      "networkmanager"
      "scanner"
      "lp"
      "libvirtd"
      "video"
      "audio"
      "vboxusers"
      "adbusers"
      "i2c"

      # zmk
      "uucp"
      "dialout"
    ];

    packages = [ pkgs.home-manager ];
    linger = true;

    openssh.authorizedKeys.keys = [ ];
  };
}
