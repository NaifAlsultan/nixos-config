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
  };

  # OpenCode saves changes from its settings dialog to cli.json, which fails on
  # a store link. Install a writable copy, reset to the declared settings on
  # every switch.
  home.activation.opencodeCliSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run rm -f "${config.xdg.configHome}/opencode/cli.json"
    run install -Dm644 ${cliSettings} "${config.xdg.configHome}/opencode/cli.json"
  '';
}
