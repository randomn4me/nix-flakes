{ pkgs, ... }:

{ 
  services = {
    udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "never";

      settings = {
        program_options = {
	  terminal = "alacritty --working-directory";
	  notify_command = "notify-send --app-name=udiskie --urgency=normal --category=system udiskie '{event}: {device_presentation}'";
	};
      };
    };
  };
}

