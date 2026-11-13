{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:

let
  # Terminal client settings. Home Manager's `tui` option writes tui.json,
  # which OpenCode 2 no longer reads.
  cliSettings = (pkgs.formats.json { }).generate "cli.json" {
    "$schema" = "https://opencode.ai/v2/cli.json";
    # Show images from tool results (e.g. rendered book figures) in the transcript.
    session = {
      image_preview = true;
      sidebar = "hide";
    };
  };
in
{
  programs.opencode = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "opencode";
      paths = [ unstable.opencode ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      # Don't load skills from ~/.claude or project .claude dirs, and keep the
      # claude that the Claude Agent provider runs from sending telemetry.
      postBuild = ''
        wrapProgram $out/bin/opencode \
          --set OPENCODE_DISABLE_CLAUDE_CODE 1 \
          --set CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC 1
      '';
      inherit (unstable.opencode) meta version;
    };
    extraPackages = [
      pkgs.python3
      # pdftoppm and pdftotext, for rendering and searching book pages.
      pkgs.poppler-utils
    ];
    settings = {
      shell = "${pkgs.bash}/bin/bash";
      share = "disabled";
      default_agent = "assistant";
    };
    # Claude Code's base prompt stays underneath with the Claude Agent provider;
    # this counters its coding-only framing.
    agents.assistant = ''
      ---
      description: General-purpose assistant for any topic
      mode: primary
      ---

      In this session you act as a general-purpose assistant, not only a coding tool. Requests can be on any subject: learning, research, writing, analysis, everyday questions, or software.

      Do not treat a request as a software engineering task, or relate it to the current working directory, unless it is clearly about code or files there. Guidance about writing code applies only when you are working on code.

      Only share URLs that the user gave you, that came from a page you fetched, or that you are confident exist. This applies to every subject, not just programming.

      Answer directly and match the depth to the question.

      When the current project has instructions, follow them. They define how to work in that project.
    '';
    commands.ask = ''
      ---
      description: Ask without taking action
      ---

      $ARGUMENTS

      This is only a question, not a request to act. Answer it, and use tools as needed to investigate, such as reading files, searching, or running commands that only inspect. Do not edit or create files, run commands that change state, commit, install anything, or take other actions. If a change would help, describe it and wait for me to ask for it.
    '';
    commands.handoff = ''
      ---
      description: Hand off to a fresh agent
      ---

      Write a handoff prompt so an agent with fresh context can carry out the work from this session. I'll paste it as the first message of a new session. That agent has none of this conversation, so the prompt must stand on its own. Write it to that agent.

      Focus for the next session, if I gave one: $ARGUMENTS

      Get this session's ID by running `echo "$OPENCODE_SESSION_ID"` with your shell tool. Use tools as needed, such as to check files or confirm details, but don't change anything or start on the work.

      Your last reply must be the prompt and nothing else, because I copy the whole reply with /copy. Don't put an introduction before it, such as "Here is the handoff prompt:", a closing remark after it, or a code fence around it.

      Include:
      - The goal, and the current state of the work.
      - The plan, as concrete steps.
      - The decisions we made, each with the reason and the alternatives we rejected. A fresh agent loses the why first, so keep it.
      - Constraints and preferences I stated.
      - Open questions and known risks.
      - The relevant files, commands, and links.
      - What was verified and what was only assumed. Label anything you didn't check, because the next agent will trust the prompt.
      - A section on the previous session. Give its ID and project directory, and say that the full transcript can be exported with `opencode session export <ID> > /tmp/<ID>.json` and searched there (user messages are in `.text`, assistant turns in `.content`) for the detailed reasoning behind a decision. Say that the agent shouldn't read the whole export into context, and that this prompt wins where it conflicts with an earlier turn in the transcript.

      Reference existing artifacts such as specs, plans, issues, commits, and diffs by path or URL instead of copying them. Keep the prompt as short as completeness allows. Redact secrets such as API keys, tokens, and passwords.
    '';
  };

  # Web search through Claude Code's WebSearch tool on Haiku, using the Claude
  # subscription. OpenCode loads plugin files from this folder.
  xdg.configFile."opencode/plugins/claude-websearch.ts".source = ./opencode-claude-websearch.ts;

  # OpenCode saves changes from its settings dialog to cli.json, which fails on
  # a store link. Install a writable copy, reset to the declared settings on
  # every switch.
  home.activation.opencodeCliSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run rm -f "${config.xdg.configHome}/opencode/cli.json"
    run install -Dm644 ${cliSettings} "${config.xdg.configHome}/opencode/cli.json"
  '';
}
