{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  programs.claude-code = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "claude-code";
      paths = [ unstable.claude-code ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/claude --suffix PATH : ${pkgs.python3}/bin
      '';
      inherit (unstable.claude-code) meta version;
    };
    settings = {
      env.CLAUDE_CODE_SHELL = "${pkgs.bash}/bin/bash";
      permissions = {
        defaultMode = "default";
        allow = [
          "Read(//**)"
          "Edit(//**)"
          "Bash"
          "WebFetch"
          "WebSearch"
        ];
      };
    };
    context = ''
      Do not add Co-Authored-By trailers or other attribution lines to git commits or pull requests.
    '';
  };

  # Claude Code saves changes (e.g. /effort) to settings.json, which fails on a
  # store link. Keep Home Manager's generated file but install a writable copy,
  # reset to the declared settings on every switch.
  home.file."${config.programs.claude-code.configDir}/settings.json".enable = false;
  home.activation.claudeCodeSettings =
    let
      settings = config.home.file."${config.programs.claude-code.configDir}/settings.json".source;
    in
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run rm -f "${config.programs.claude-code.configDir}/settings.json"
      run install -Dm644 ${settings} "${config.programs.claude-code.configDir}/settings.json"
    '';
}
