{ lib, ... }:
{
  xdg.configFile.mail-signatures.text = lib.strings.concatLines [
    "Bei Fragen, melde dich gerne."
    "Wenn Fragen aufkommen sollten, kannst du mir gerne schreiben."
    "Melde dich gerne, wenn etwas unklar ist."
    "Bei Rückfragen kannst du dich gerne melden."
    "Falls was unklar sein sollte, melde dich."
  ];
}
