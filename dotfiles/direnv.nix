{
  # Loads a project's dev environment into the current Nushell on `cd`
  # (via an `.envrc` containing `use flake`), instead of `nix develop`
  # dropping into bash. nix-direnv caches the environment between visits.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableNushellIntegration = true;
  };
}
