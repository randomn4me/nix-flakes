{ pkgs ? import <nixpkgs> { } }: rec {
  cloudsend = pkgs.callPackage ./cloudsend { };
}
