{ pkgs, ... }:
{
  home.packages = [ pkgs.claude-code ];

  # Global instructions, prepended to every Claude Code session.
  home.file.".claude/CLAUDE.md".text = ''
    - always use conventional commit messages
    - never place ai usage disclaimers and references in commit msgs
    - don't as silly questions
    - always strive for the most practical solutions
    - always verify that your solution is working
    - use devide and conquour to tackle big tasks
    - make use of subagents if this seems sensible
    - be concise, but don't skip on necessary details
  '';
}
