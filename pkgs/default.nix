{ pkgs ? import <nixpkgs> { } }: rec {
  #sharetechmono = pkgs.callPackage ./sharetechmono { }; # obsolete due to pkgs.google-fonts
  #tmx = pkgs.callPackage ./tmx { };
  cloudsend = pkgs.callPackage ./cloudsend { };
}
