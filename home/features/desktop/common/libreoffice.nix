{ pkgs, ... }:
{
  home.packages = [ pkgs.libreoffice ];

  xdg.mimeApps.defaultApplications = {
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "writer.desktop";
    "application/vnd.oasis.opendocument.text" = "writer.desktop";
  };
}
