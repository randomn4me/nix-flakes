{ pkgs, config, ... }:
let
  home = config.home.homeDirectory;
  convert = "${pkgs.imagemagick}/bin/convert";

  basename = "${pkgs.coreutils}/bin/basename";
  mkdir = "${pkgs.coreutils}/bin/mkdir";
  mktemp = "${pkgs.coreutils}/bin/mktemp";
  echo = "${pkgs.coreutils}/bin/echo";
  date = "${pkgs.coreutils}/bin/date";
  test = "${pkgs.coreutils}/bin/test";
  rm = "${pkgs.coreutils}/bin/rm";
  tr = "${pkgs.coreutils}/bin/tr";

  scanimage = "${pkgs.sane-backends}/bin/scanimage";

  scan = pkgs.writeShellScriptBin "scan" ''
    device='brother4:net1;dev0'
    tmpdir="$(${mktemp} -d)"
    tmpscan="$tmpdir/scan"
    outdir="${home}/var/scans"

    usage() {
      ${echo} "Usage: $(${basename} $0) [-h]"
      exit 1
    }

    ${test} "$1" = "-h" && usage

    ${mkdir} -p $outdir
    name_sanitized="$(${echo} $@ | ${tr} [A-Z\ ] [a-z\-])"
    outfile="$outdir/$(${date} +%F_%Hh%Mm%Ss).pdf"

    ( ${scanimage} -d "$device" -o "$tmpscan.png" && \
      ${convert} "$tmpscan.png" "$outfile" && \
      ${rm} -rf $tmpdir ) > /dev/null & disown
  '';
in {
  home.packages = [ scan ];
}
