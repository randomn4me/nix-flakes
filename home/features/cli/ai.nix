{ ... }:
{
  custom.ai = {
    enable = true;
    tools = [
      "claude"
      "herdr"
    ];

    # Shared by every agent: CLAUDE.md for Claude Code, AGENTS.md for the
    # rest, so switching tools does not switch the rules.
    instructions = ''
      - always use conventional commit messages
      - never place ai usage disclaimers and references in commit msgs
      - don't as silly questions
      - always strive for the most practical solutions
      - always verify that your solution is working
      - use devide and conquour to tackle big tasks
      - make use of subagents if this seems sensible
      - be concise, but don't skip on necessary details
    '';
  };
}
