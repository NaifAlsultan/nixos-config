{ pkgs, unstable, ... }:

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
    extraPackages = [ pkgs.python3 ];
    settings = {
      shell = "${pkgs.bash}/bin/bash";
      share = "disabled";
    };
  };
}
