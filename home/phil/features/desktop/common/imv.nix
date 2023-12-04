{
  programs.imv.enable = true;

  xdg = {
    desktopEntries = {
      imv = {
        name = "imv";
        genericName = "Image Viewer";
        comment = "Viewer for Image files";
        exec = "imv %F";
        mimeType = [ "image/*" ];
        type = "Application";
        categories = [ "Utility" ];
      };
    };

    mimeApps.defaultApplications = {
      "image/jpeg" = [ "imv.desktop" ];
    };
  };

}
