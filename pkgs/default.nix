{
  pkgs ? import <nixpkgs> { },
}:
{
  python-icore = pkgs.python3Packages.callPackage ./core { };
}
