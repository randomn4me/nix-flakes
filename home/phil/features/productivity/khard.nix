{ pkgs, ... }: 
{
  home.packages = with pkgs; [
    khard
  ];

  xdg.configFile."khard/khard.conf".text = ''
    [addressbooks]
    [[audacis]]
    path = ~/var/vdirsyncer/audacis_contacts/contacts
  ''
}
