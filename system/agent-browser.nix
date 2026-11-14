{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  agentBrowser = inputs.agent-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home-manager.users.naif.programs.opencode.settings.mcp.servers.agent-browser = {
    type = "local";
    command = [ (lib.getExe agentBrowser) ];
  };

  # programs.chromium also writes its policies for Google Chrome, which would put its extensions into agent profiles.
  environment.etc."opt/chrome/policies/managed/default.json".enable = false;
  environment.etc."opt/chrome/policies/managed/extra.json".enable = false;
}
