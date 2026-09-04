{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.ai;

  # Every agent below is backed by an upstream home-manager module, so this
  # module writes no config files of its own. All it does is turn one list of
  # tool names into the matching programs.* blocks and keep the instruction
  # files in sync between them -- per-tool knobs stay reachable under
  # programs.<backend> for anything not wrapped here.
  backends = {
    claude = "claude-code";
    codex = "codex";
    opencode = "opencode";
    mistral = "mistral-vibe";
    crush = "crush";
    aider = "aider-chat";
    herdr = "herdr";
  };

  enabled = tool: elem tool cfg.tools;

  # Claude Code reads CLAUDE.md; every other agent that takes a global
  # instruction file reads AGENTS.md. Both get the same text, so the rules
  # cannot drift depending on which tool happens to be driving.
  agentsMdTools = [
    "codex"
    "opencode"
  ];
in
{
  # herdr gets its own file: it is the one tool here whose full config is
  # worth modelling option by option rather than passing through.
  imports = [ ./herdr.nix ];

  options.custom.ai = {
    enable = mkEnableOption "AI coding agents";

    tools = mkOption {
      description = ''
        Which agents to install. Names map onto the upstream home-manager
        modules (claude -> programs.claude-code, mistral ->
        programs.mistral-vibe, and so on).
      '';
      type = types.listOf (types.enum (attrNames backends));
      default = [
        "claude"
        "herdr"
      ];
      example = [
        "claude"
        "codex"
        "herdr"
      ];
    };

    instructions = mkOption {
      description = ''
        Instructions shared by every agent, written to ~/.claude/CLAUDE.md for
        Claude Code and to AGENTS.md for the agents that read that instead.
        Only the tools actually listed in `tools` get a file.
      '';
      type = types.lines;
      default = "";
    };

    claude.settings = mkOption {
      description = ''
        Claude Code settings.json -- permissions, model, hooks, statusline.
        See <https://docs.claude.com/en/docs/claude-code/settings>.
      '';
      type = (pkgs.formats.json { }).type;
      default = { };
      example = {
        model = "opus";
        permissions.allow = [ "Bash(git diff:*)" ];
      };
    };

    mcpServers = mkOption {
      description = ''
        MCP servers declared once and handed to every listed agent that
        supports them; the upstream modules translate this into each tool's
        own schema. Leave empty to not enable MCP at all.
      '';
      type = types.attrsOf types.anything;
      default = { };
      example = literalExpression ''
        {
          fetch = {
            command = "uvx";
            args = [ "mcp-server-fetch" ];
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    programs = mkMerge [
      # Agents that take a global instruction file.
      (mkIf (enabled "claude") {
        claude-code = {
          enable = true;
          context = cfg.instructions;
          settings = cfg.claude.settings;
        };
      })
      (mkIf (enabled "codex") {
        codex = {
          enable = true;
          context = cfg.instructions;
        };
      })
      (mkIf (enabled "opencode") {
        opencode = {
          enable = true;
          context = cfg.instructions;
        };
      })

      # These ship no global-instruction option upstream -- they pick up a
      # per-project AGENTS.md instead, so there is nothing to write here.
      (mkIf (enabled "mistral") { mistral-vibe.enable = true; })
      (mkIf (enabled "crush") { crush.enable = true; })
      (mkIf (enabled "aider") { aider-chat.enable = true; })

      (mkIf (cfg.mcpServers != { }) {
        mcp = {
          enable = true;
          servers = cfg.mcpServers;
        };
      })
    ];

    warnings =
      optional (
        cfg.claude.settings != { } && !(enabled "claude")
      ) "custom.ai: claude.settings is set but \"claude\" is not in custom.ai.tools; it will be ignored."
      ++ optional (
        cfg.instructions != "" && !(enabled "claude") && !(any enabled agentsMdTools)
      ) "custom.ai: instructions are set but no listed tool reads a global instruction file.";
  };
}
