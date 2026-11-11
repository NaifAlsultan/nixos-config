{ pkgs, inputs, ... }:

{
  # Lets any module take `unstable` as an argument, for packages that need
  # newer versions than the stable channel.
  _module.args.unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };

  imports = [
    ../dotfiles/claude-code.nix
    ../dotfiles/direnv.nix
    ../dotfiles/ghostty.nix
    ../dotfiles/git.nix
    ../dotfiles/helix.nix
    ../dotfiles/nushell.nix
    ../dotfiles/opencode.nix
    ../dotfiles/starship.nix
  ];

  # Allows unfree packages in impure commands, e.g. `nix run --impure nixpkgs#...`.
  home.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";

  home.packages = with pkgs; [
    obsidian
    typst
    unzip
    nerd-fonts.symbols-only
    noto-fonts
  ];
}
