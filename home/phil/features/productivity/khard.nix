{ pkgs, config, ... }: {
  home.packages = with pkgs; [ khard ];

  xdg.configFile."khard/khard.conf".text = ''
    [addressbooks]
    [[audacis]]
    path = ${config.home.homeDirectory}/var/vdirsyncer/audacis_contacts/contacts
  '';
}
