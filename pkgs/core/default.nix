{
  pkgs ? import <nixpkgs> { },
}:

pkgs.python3Packages.buildPythonApplication {
  pname = "python-icore";
  version = "1.0.0";

  propagatedBuildInputs = with pkgs.python3Packages; [
    tabulate
    pandas
    lxml
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp core.py $out/bin/core
    chmod +x $out/bin/core
  '';

  src = ./.;
}
