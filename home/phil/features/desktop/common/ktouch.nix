{ pkgs, ... }: {
  home.packages = with pkgs; [ ktouch ];

  xdg.desktopEntries = {
    ktouch = {
      name = "KTouch (Wayland)";
      genericName = "Touch Typing Tutor";
      exec = "env QT_QPA_PLATFORM=xcb ktouch";
      icon = "ktouch";
      type = "Application";
      categories = [ "Qt" "KDE" "Education" ];
    };
  };

}
