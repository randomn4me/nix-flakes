# Helpers for writing Hyprland's Lua config from Nix.
#
# Home Manager turns every `settings.<name>` entry into an `hl.<name>(...)`
# call (one call per element for lists). An attribute value with `_args`
# spreads that list across the call's arguments, and `mkLuaInline` passes a
# string through as raw Lua instead of quoting it -- which is how dispatchers
# like `hl.dsp.exec_cmd(...)` get past the Nix -> Lua string escaping.
{ lib }:
rec {
  # The modifier every binding hangs off.
  mod = "SUPER";

  # A Lua string literal. JSON escaping matches Lua's for the ASCII commands
  # and store paths used here.
  str = builtins.toJSON;

  exec = cmd: "hl.dsp.exec_cmd(${str cmd})";

  # hl.bind(<keys>, <dispatcher>, <opts>). `dispatcher` is raw Lua: either an
  # `hl.dsp.*` call or a `function() ... end`.
  bindWith = opts: keys: dispatcher: {
    _args = [
      keys
      (lib.generators.mkLuaInline dispatcher)
    ]
    ++ lib.optional (opts != { }) opts;
  };

  bind = bindWith { };

  # binde: repeat while held.
  bindRepeat = bindWith { repeating = true; };

  # bindl: still fires while an input inhibitor (hyprlock) is up.
  bindLocked = bindWith { locked = true; };

  # bindle: both of the above.
  bindLockedRepeat = bindWith {
    locked = true;
    repeating = true;
  };
}
