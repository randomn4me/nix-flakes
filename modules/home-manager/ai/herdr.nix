{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.ai;
  hcfg = cfg.herdr;

  # Every option below defaults to null and nulls are stripped before the TOML
  # is generated, so config.toml carries only what is set here and everything
  # else stays on herdr's own default instead of being frozen into this module.
  # Upstream defaults are quoted in the descriptions rather than duplicated as
  # Nix defaults, which keeps this from drifting when herdr changes one.
  opt =
    type: description:
    mkOption {
      type = types.nullOr type;
      default = null;
      inherit description;
    };

  # Strips unset values so config.toml carries only what was set here. Lists
  # are walked too, since a keys.command entry leaves its optional fields null
  # and TOML has no null to write them as. Empty lists are dropped along with
  # empty tables: both list options below are empty upstream anyway, so an
  # empty one carries no meaning worth emitting.
  cleanup =
    value:
    if isList value then
      map cleanup value
    else if isAttrs value then
      filterAttrs (_: v: !((isAttrs v && v == { }) || (isList v && v == [ ]))) (
        mapAttrs (_: cleanup) (filterAttrs (_: v: v != null) value)
      )
    else
      value;

  themeNames = [
    "catppuccin"
    "catppuccin-latte"
    "terminal"
    "tokyo-night"
    "tokyo-night-day"
    "dracula"
    "nord"
    "gruvbox"
    "gruvbox-light"
    "one-dark"
    "one-light"
    "solarized"
    "solarized-light"
    "kanagawa"
    "kanagawa-lotus"
    "rose-pine"
    "rose-pine-dawn"
    "vesper"
  ];

  # Tokens herdr recognises in sidebar rows. Any other string is passed through
  # as a custom token, so this is a documentation aid, not a constraint.
  colorTokens = [
    "accent"
    "panel_bg"
    "sidebar_bg"
    "active_row_bg"
    "selection_bg"
    "surface0"
    "surface1"
    "surface_dim"
    "overlay0"
    "overlay1"
    "text"
    "subtext0"
    "mauve"
    "green"
    "yellow"
    "red"
    "blue"
    "teal"
    "peach"
  ];

  # Agents herdr can detect, each overridable to on/off independently of the
  # global sound switch.
  soundAgents = [
    "pi"
    "claude"
    "codex"
    "gemini"
    "cursor"
    "devin"
    "agy"
    "cline"
    "open_code"
    "github_copilot"
    "kimi"
    "kiro"
    "droid"
    "amp"
    "grok"
    "hermes"
    "kilo"
    "qodercli"
    "qwen"
    "maki"
  ];

  # One chord, or a list of chords bound to the same action.
  bindingType = types.either types.str (types.listOf types.str);

  # action -> upstream default (null meaning unset) plus what it does.
  keyBindings = {
    help = {
      default = "prefix+?";
      desc = "Open keybinding help.";
    };
    settings = {
      default = "prefix+s";
      desc = "Open settings.";
    };
    new_workspace = {
      default = "prefix+shift+n";
      desc = "Create a new workspace.";
    };
    new_worktree = {
      default = "prefix+shift+g";
      desc = "Create a Git worktree from the selected workspace.";
    };
    open_worktree = {
      default = null;
      desc = "Open an existing Git worktree from the selected workspace.";
    };
    remove_worktree = {
      default = null;
      desc = "Delete the selected managed worktree checkout after confirmation.";
    };
    rename_workspace = {
      default = "prefix+shift+w";
      desc = "Rename the selected workspace.";
    };
    close_workspace = {
      default = "prefix+shift+d";
      desc = "Close the selected workspace.";
    };
    workspace_picker = {
      default = "prefix+w";
      desc = "Open the workspace navigation surface.";
    };
    goto = {
      default = "prefix+g";
      desc = "Open the session navigator.";
    };
    navigate_workspace_up = {
      default = "up";
      desc = "Move workspace selection up in navigate mode.";
    };
    navigate_workspace_down = {
      default = "down";
      desc = "Move workspace selection down in navigate mode.";
    };
    navigate_pane_left = {
      default = "h";
      desc = "Focus the pane to the left in navigate mode; left arrow is always an alias.";
    };
    navigate_pane_down = {
      default = "j";
      desc = "Focus the pane below in navigate mode.";
    };
    navigate_pane_up = {
      default = "k";
      desc = "Focus the pane above in navigate mode.";
    };
    navigate_pane_right = {
      default = "l";
      desc = "Focus the pane to the right in navigate mode; right arrow is always an alias.";
    };
    detach = {
      default = "prefix+q";
      desc = "Detach from server/client mode, or exit --no-session mode.";
    };
    reload_config = {
      default = "prefix+shift+r";
      desc = "Reload config.toml in the running app/server.";
    };
    open_notification_target = {
      default = "prefix+o";
      desc = "Focus the currently visible notification target.";
    };
    previous_workspace = {
      default = null;
      desc = "Select the previous workspace.";
    };
    next_workspace = {
      default = null;
      desc = "Select the next workspace.";
    };
    previous_agent = {
      default = null;
      desc = "Focus the previous agent shown in the agent panel.";
    };
    next_agent = {
      default = null;
      desc = "Focus the next agent shown in the agent panel.";
    };
    focus_agent = {
      default = null;
      desc = "Focus an agent by index 1-9.";
    };
    new_tab = {
      default = "prefix+c";
      desc = "Create a new tab in the active workspace.";
    };
    rename_tab = {
      default = "prefix+shift+t";
      desc = "Rename the active tab.";
    };
    previous_tab = {
      default = "prefix+p";
      desc = "Select the previous tab.";
    };
    next_tab = {
      default = "prefix+n";
      desc = "Select the next tab.";
    };
    move_tab_previous = {
      default = null;
      desc = "Move the active tab one position toward the front.";
    };
    move_tab_next = {
      default = null;
      desc = "Move the active tab one position toward the back.";
    };
    switch_tab = {
      default = "prefix+1..9";
      desc = "Switch to tab 1-9.";
    };
    switch_workspace = {
      default = null;
      desc = "Switch to workspace 1-9 from prefix mode.";
    };
    close_tab = {
      default = "prefix+shift+x";
      desc = "Close the active tab.";
    };
    rename_pane = {
      default = "prefix+shift+p";
      desc = "Rename the focused pane.";
    };
    edit_scrollback = {
      default = "prefix+e";
      desc = "Open the focused pane scrollback in $EDITOR.";
    };
    copy_mode = {
      default = "prefix+[";
      desc = "Enter keyboard copy mode for the focused pane.";
    };
    focus_pane_left = {
      default = "prefix+h";
      desc = "Focus the pane to the left.";
    };
    focus_pane_down = {
      default = "prefix+j";
      desc = "Focus the pane below.";
    };
    focus_pane_up = {
      default = "prefix+k";
      desc = "Focus the pane above.";
    };
    focus_pane_right = {
      default = "prefix+l";
      desc = "Focus the pane to the right.";
    };
    swap_pane_left = {
      default = "prefix+shift+h";
      desc = "Swap the focused pane with the pane to the left.";
    };
    swap_pane_down = {
      default = "prefix+shift+j";
      desc = "Swap the focused pane with the pane below.";
    };
    swap_pane_up = {
      default = "prefix+shift+k";
      desc = "Swap the focused pane with the pane above.";
    };
    swap_pane_right = {
      default = "prefix+shift+l";
      desc = "Swap the focused pane with the pane to the right.";
    };
    cycle_pane_next = {
      default = "prefix+tab";
      desc = "Cycle to the next pane.";
    };
    cycle_pane_previous = {
      default = "prefix+shift+tab";
      desc = "Cycle to the previous pane.";
    };
    last_pane = {
      default = null;
      desc = "Focus the last focused pane across workspaces and tabs.";
    };
    split_vertical = {
      default = "prefix+v";
      desc = "Split pane vertically (side by side).";
    };
    split_horizontal = {
      default = "prefix+minus";
      desc = "Split pane horizontally (stacked).";
    };
    close_pane = {
      default = "prefix+x";
      desc = "Close the focused pane.";
    };
    zoom = {
      default = "prefix+z";
      desc = "Toggle zoom for the focused pane.";
    };
    resize_mode = {
      default = "prefix+r";
      desc = "Enter resize mode.";
    };
    resize_pane_left = {
      default = null;
      desc = "Resize the focused pane toward the left.";
    };
    resize_pane_down = {
      default = null;
      desc = "Resize the focused pane downward.";
    };
    resize_pane_up = {
      default = null;
      desc = "Resize the focused pane upward.";
    };
    resize_pane_right = {
      default = null;
      desc = "Resize the focused pane toward the right.";
    };
    toggle_sidebar = {
      default = "prefix+b";
      desc = "Toggle sidebar collapse.";
    };
  };

  mkBinding =
    _name: spec:
    opt bindingType (
      spec.desc + (if spec.default == null then " Unset by default." else " Default: `${spec.default}`.")
    );

  sidebarRowsType = types.listOf (types.listOf types.str);
in
{
  options.custom.ai.herdr = {
    onboarding = opt types.bool "Show the first-run onboarding flow. Default: `true`.";

    theme = {
      name = opt (types.enum themeNames) "Built-in theme name. Default: `catppuccin`.";
      auto_switch = opt types.bool "Follow the host terminal's light/dark appearance, switching between `dark_name` and `light_name`. Default: `false`.";
      dark_name = opt (types.enum themeNames) "Theme used when `auto_switch` picks a dark appearance.";
      light_name = opt (types.enum themeNames) "Theme used when `auto_switch` picks a light appearance.";
      custom = opt (types.attrsOf types.str) ''
        Per-token colour overrides applied on top of the selected base theme.
        Accepts hex (`#89b4fa`), named colours (`cyan`), or `rgb(137,180,250)`.
        Known tokens: ${concatStringsSep ", " colorTokens}.
      '';
    };

    terminal = {
      default_shell = opt types.str "Executable used for new interactive panes. Empty falls back to `$SHELL`, then `/bin/sh`.";
      shell_mode = opt (types.enum [
        "auto"
        "login"
        "non_login"
      ]) "Startup mode for new interactive pane shells. Default: `auto`.";
      new_cwd = opt types.str ''
        Working directory policy for new panes, tabs and workspaces: `follow`,
        `home`, `current`, or any other value taken as a literal path.
        Default: `follow`.
      '';
    };

    session = {
      resume_agents_on_restore = opt types.bool "Resume supported AI-agent panes into their native conversation sessions when a herdr session is restored. Default: `true`.";
    };

    server = {
      headless_cols = opt types.ints.unsigned "Virtual terminal width used while no client is attached. Default: `120`.";
      headless_rows = opt types.ints.unsigned "Virtual terminal height used while no client is attached. Default: `40`.";
    };

    update = {
      channel = opt (types.enum [
        "stable"
        "preview"
      ]) "Update channel. Default: `stable`.";
      version_check = opt types.bool "Check for new versions on startup. Default: `true`.";
      manifest_check = opt types.bool "Check the release manifest on startup. Default: `true`.";
    };

    keys = mapAttrs mkBinding keyBindings // {
      prefix = opt types.str "Prefix key that enters prefix mode. Default: `ctrl+b`.";
      remote_image_paste = opt types.str "Local-client shortcut that sends a clipboard image to a remote herdr session. Default: `ctrl+v`.";

      indexed = {
        tabs = opt types.str "Modifier combo for tab shortcuts 1-9. Unset by default.";
        workspaces = opt types.str "Modifier combo for workspace shortcuts 1-9. Unset by default.";
        agents = opt types.str "Modifier combo for agent shortcuts 1-9. Unset by default.";
      };

      command = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              key = mkOption {
                type = bindingType;
                description = "Key that runs the command; `prefix+g` for prefix mode or a modified chord for direct mode.";
              };
              command = mkOption {
                type = types.str;
                description = "Command to run.";
              };
              type = mkOption {
                type = types.enum [
                  "shell"
                  "pane"
                  "popup"
                  "plugin_action"
                ];
                default = "shell";
                description = "Execution mode.";
              };
              description = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Label shown in the keybinding help.";
              };
              width = mkOption {
                type = types.nullOr (types.either types.ints.unsigned types.str);
                default = null;
                description = "Popup width in cells or as a percentage string, when `type = \"popup\"`.";
              };
              height = mkOption {
                type = types.nullOr (types.either types.ints.unsigned types.str);
                default = null;
                description = "Popup height in cells or as a percentage string, when `type = \"popup\"`.";
              };
            };
          }
        );
        default = [ ];
        description = "Prefix-mode custom command bindings.";
      };
    };

    ui = {
      sidebar_width = opt types.ints.unsigned "Expanded sidebar width in columns. Default: `26`.";
      sidebar_min_width = opt types.ints.unsigned "Minimum expanded sidebar width. Default: `18`.";
      sidebar_max_width = opt types.ints.unsigned "Maximum expanded sidebar width. Default: `36`.";
      sidebar_start_collapsed = opt types.bool "Start with the sidebar collapsed. Default: `false`.";
      sidebar_collapsed_mode = opt (types.enum [
        "compact"
        "hidden"
      ]) "Collapsed sidebar presentation. Default: `compact`.";
      mobile_width_threshold = opt types.ints.unsigned "Terminal width at or below which the single-column mobile layout is used. Default: `64`.";
      mouse_capture = opt types.bool "Capture mouse input for herdr's own mouse UI. Default: `true`.";
      copy_on_select = opt types.bool "Copy text selected with the mouse. Default: `true`.";
      host_cursor = opt (types.enum [
        "auto"
        "native"
        "drawn"
      ]) "Host cursor policy. Default: `auto`.";
      right_click_passthrough_modifier = opt types.str "Modifier that lets right-click gestures reach the pane's application. Empty disables it.";
      redraw_on_focus_gained = opt types.bool "Force a full redraw when the outer terminal regains focus. Default: `true`.";
      mouse_scroll_lines = opt types.ints.positive "Lines scrolled per wheel notch. Default: `3`.";
      confirm_close = opt types.bool "Confirm before closing a workspace. Default: `true`.";
      prompt_new_tab_name = opt types.bool "Ask for a tab name when creating a tab. Default: `true`.";
      prompt_new_workspace_name = opt types.bool "Ask for a workspace name on interactive creation. Default: `false`.";
      pane_borders = opt types.bool "Draw borders around split panes. Default: `true`.";
      pane_outer_borders = opt types.bool "Draw a border along the outside edge of the pane area. Default: `true`.";
      pane_scrollbars = opt types.bool "Draw interactive scrollbars beside panes. Default: `true`.";
      pane_gaps = opt types.bool "Keep split panes visually separated rather than sharing divider borders. Default: `true`.";
      show_agent_labels_on_pane_borders = opt types.bool "Show agent labels in pane borders when no manual pane label is set. Default: `false`.";
      hide_tab_bar_when_single_tab = opt types.bool "Hide the tab row when a workspace has only one tab. Default: `false`.";
      tab_bar_position = opt (types.enum [
        "top"
        "bottom"
      ]) "Desktop tab row placement. Default: `top`.";
      tab_bar_right = mkOption {
        type = types.listOf (types.attrsOf types.anything);
        default = [ ];
        description = ''
          Entries shown at the right edge of the tab row, each tagged with
          `type`: `zoom`, `hostname`, `datetime` (`format`), `text` (`text`),
          or `command` (`command`, `interval_seconds`, `timeout_seconds`).
        '';
        example = literalExpression ''
          [
            { type = "datetime"; format = "%H:%M"; }
            { type = "hostname"; }
          ]
        '';
      };
      tab_bar_right_separator = opt types.str "Text inserted between visible right-side tab bar entries. Default: a single space.";
      window_title = opt types.str "Outer terminal window title; empty leaves it alone. Default: `{hostname}: {workspace}`.";
      agent_panel_sort = opt (types.enum [
        "spaces"
        "priority"
      ]) "Agent sidebar ordering. Default: `spaces`.";
      status_indicators = opt (types.enum [
        "dots"
        "symbols"
      ]) "Agent status indicator style. Default: `dots`.";
      accent = opt types.str ''
        Accent colour for highlights, borders and navigation UI. Accepts hex,
        a named colour, or `rgb(r,g,b)`. Default: `cyan`.
      '';

      sidebar = {
        agents = {
          rows = opt sidebarRowsType ''
            Row composition for agent entries. Known tokens: `state_icon`,
            `state_text`, `workspace`, `tab`, `pane`, `agent`,
            `terminal_title`, `terminal_title_stripped`; any other string is a
            custom token. Default:
            `[ [ "state_icon" "workspace" "tab" ] [ "agent" ] ]`.
          '';
          rows_by_agent = opt (types.attrsOf sidebarRowsType) "Per-agent row overrides, keyed by agent name.";
          row_gap = opt types.ints.unsigned "Blank lines between agent rows. Default: `0`.";
        };
        spaces = {
          rows = opt sidebarRowsType ''
            Row composition for workspace entries. Known tokens: `state_icon`,
            `state_text`, `workspace`, `branch`, `git_status`. Default:
            `[ [ "state_icon" "workspace" ] [ "branch" "git_status" ] ]`.
          '';
          row_gap = opt types.ints.unsigned "Blank lines between workspace rows. Default: `0`.";
        };
      };

      toast = {
        delivery = opt (types.enum [
          "off"
          "herdr"
          "terminal"
          "system"
        ]) "Where background-event toasts are delivered. Default: `off`.";
        delay_seconds = opt types.ints.unsigned "Delay before a toast is raised. Default: `1`.";
        herdr.position = opt (types.enum [
          "top-left"
          "top-right"
          "bottom-left"
          "bottom-right"
        ]) "Placement of herdr-drawn toasts. Default: `bottom-right`.";
        clipboard = {
          enabled = opt types.bool "Show a toast when something is copied. Default: `true`.";
          position = opt (types.enum [
            "top-left"
            "top-center"
            "top-right"
            "bottom-left"
            "bottom-center"
            "bottom-right"
          ]) "Placement of clipboard toasts. Default: `bottom-center`.";
        };
      };

      sound = {
        enabled = opt types.bool "Play a sound when an agent changes state in a background workspace. Default: `true`.";
        path = opt types.path "mp3 used for all notification sounds.";
        done_path = opt types.path "mp3 used for \"done\" notifications.";
        request_path = opt types.path "mp3 used for \"request\" notifications.";
        agents = genAttrs soundAgents (
          agent:
          opt (types.enum [
            "default"
            "on"
            "off"
          ]) "Sound override for ${agent}. Default: `default`, i.e. follow `sound.enabled`."
        );
      };
    };

    worktrees = {
      directory = opt types.str "Root under which herdr creates `<repo>/<branch-slug>` checkouts. Default: `~/.herdr/worktrees`.";
    };

    advanced = {
      scrollback_limit_bytes = opt types.ints.unsigned "Scrollback retained per pane, in bytes. Default: `10000000`.";
    };

    experimental = {
      allow_nested = opt types.bool "Allow launching herdr inside an existing herdr pane. Default: `false`.";
      kitty_graphics = opt types.bool "Local Kitty graphics rendering for attached clients. Default: `false`.";
      pane_history = opt types.bool "Persist pane screen history to session-history.json. Default: `false`.";
      reveal_hidden_cursor_for_cjk_ime = opt types.bool ''
        Expose the focused pane's cursor anchor to the outer terminal even when
        the pane hid it, so native input methods keep tracking the candidate
        window. Costs a visible extra cursor in apps that hide it without
        painting a replacement. Default: `false`.
      '';
      cjk_ime_agents = opt (types.listOf types.str) ''
        Restrict `reveal_hidden_cursor_for_cjk_ime` to panes whose detected
        agent matches one of these names. Empty applies it to any pane.
      '';
      cjk_ime_cursor_shape = opt (types.enum [
        "block"
        "steady_block"
        "underline"
        "steady_underline"
        "bar"
        "steady_bar"
      ]) "Cursor shape drawn for the IME anchor. Default: `steady_block`.";
      switch_ascii_input_source_in_prefix = opt types.bool ''
        While prefix mode is active, temporarily switch the host input source
        to an ASCII-capable mode. macOS and Windows only; a no-op elsewhere.
        Default: `false`.
      '';
    };

    remote = {
      manage_ssh_config = opt types.bool ''
        Add keepalive fallbacks and private connection reuse for
        `herdr --remote`. Set false to run plain ssh unchanged. Default: `true`.
      '';
    };

    settings = mkOption {
      type = (pkgs.formats.toml { }).type;
      default = { };
      description = ''
        Escape hatch merged over everything above, for keys this module does
        not model yet.
      '';
    };
  };

  config = mkIf (cfg.enable && elem "herdr" cfg.tools) {
    programs.herdr = {
      enable = true;
      settings = recursiveUpdate (cleanup {
        inherit (hcfg) onboarding;
        inherit (hcfg)
          theme
          terminal
          session
          server
          update
          keys
          ui
          worktrees
          advanced
          experimental
          remote
          ;
      }) hcfg.settings;
    };
  };
}
