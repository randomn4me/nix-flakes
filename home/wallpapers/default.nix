builtins.listToAttrs (
  map (wallpaper: {
    inherit (wallpaper) name;
    value = builtins.fetchurl {
      inherit (wallpaper) sha256;
      url = "${wallpaper.url}.${wallpaper.ext}";
    };
  }) (builtins.fromJSON (builtins.readFile ./list.json))
)
