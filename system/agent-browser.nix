{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  agentBrowser = inputs.agent-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # agent-browser's run tool executes agent-written code as the server's user, and pages can prompt-inject that
  # agent. So the server runs where it can't see the home directory or inherit the caller's environment
  # (secrets exported by scripts, API keys). Fails closed if bubblewrap can't start.
  sandboxed = pkgs.writeShellApplication {
    name = "agent-browser-sandboxed";
    runtimeInputs = [
      pkgs.bubblewrap
      pkgs.coreutils
    ];
    text = ''
      # For callers that are already sandboxed and can't create namespaces (opencode-remote).
      if [ "''${AGENT_BROWSER_SANDBOX:-}" = off ]; then
        exec ${lib.getExe agentBrowser} "$@"
      fi

      args=(--clearenv)
      while IFS='=' read -r -d "" name value; do
        case "$name" in
          AGENT_BROWSER_* | LANG | LANGUAGE | LC_* | TZ | TZDIR | LOCALE_ARCHIVE) args+=(--setenv "$name" "$value") ;;
        esac
      done < <(env -0)

      args+=(
        --setenv HOME /tmp
        --setenv PATH /run/current-system/sw/bin
        --unshare-all
        --share-net
        --die-with-parent
        --new-session
        --ro-bind /nix/store /nix/store
        --ro-bind /etc /etc
        # Xvfb runs xkbcomp through /bin/sh.
        --ro-bind /bin /bin
        --ro-bind /run/current-system /run/current-system
        --ro-bind-try /run/opengl-driver /run/opengl-driver
        --ro-bind-try /run/systemd/resolve /run/systemd/resolve
        --ro-bind /sys /sys
        --proc /proc
        --dev /dev
        --dev-bind-try /dev/dri /dev/dri
        --tmpfs /dev/shm
        --tmpfs /tmp
        --dir /tmp/.X11-unix
      )
      # Machine-wide Chrome policies would apply to agent profiles too.
      if [ -d /etc/opt/chrome ]; then args+=(--tmpfs /etc/opt/chrome); fi

      exec bwrap "''${args[@]}" -- ${lib.getExe agentBrowser} "$@"
    '';
  };
in
{
  home-manager.users.naif.programs.opencode.settings.mcp.servers.agent-browser = {
    type = "local";
    command = [ (lib.getExe sandboxed) ];
  };

  # programs.chromium also writes its policies for Google Chrome, which would put its extensions into agent profiles.
  environment.etc."opt/chrome/policies/managed/default.json".enable = false;
  environment.etc."opt/chrome/policies/managed/extra.json".enable = false;
}
