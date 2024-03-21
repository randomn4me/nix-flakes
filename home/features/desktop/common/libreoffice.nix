{ pkgs, ... }:
{
  home.packages = [ pkgs.libreoffice ];

  mimeApps.defaultApplications = {
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "libreoffice.desktop";
  };
}
