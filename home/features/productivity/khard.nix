{ pkgs, config, ... }: {
  home.packages = with pkgs; [ khard ];

  xdg.configFile."khard/khard.conf".text = ''
    [addressbooks]

    [[audacis]]
    path=${config.home.homeDirectory}/var/contacts/audacis/contacts

    [contact table]

    display=last_name
    group_by_addressbook=no
    localize_dates=yes
    preferred_email_address_type=pref, work, home
    preferred_phone_number_type=pref, cell, home
    reverse=no
    show_nicknames=no
    show_uids=yes
    sort=last_name

    [general]

    debug=no
    default_action=list
    editor=vim, -i, NONE
    merge_editor=vimdiff
  '';

  #programs.khard = {
  #  enable = true;

  #  settings = {
  #    general = {
  #      debug = false;
  #      default_action = "list";

  #      editor = [ "vim" "-i" "NONE" ];

  #      merge_editor = "vimdiff";
  #    };

  #    "contact table" = {
  #      display = "last_name";
  #      sort = "last_name";

  #      group_by_addressbook = false;

  #      reverse = false;

  #      show_uids = true;
  #      show_nicknames = false;

  #      localize_dates = true;

  #      preferred_phone_number_type = ["pref" "cell" "home"];
  #      preferred_email_address_type = ["pref" "work" "home"];
  #    };
  #  };
  #};
}
