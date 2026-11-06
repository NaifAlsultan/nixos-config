{ pkgs, inputs, ... }:

let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  programs.opencode = {
    enable = true;
    package = unstable.opencode;
    settings = {
      shell = "${pkgs.bash}/bin/bash";
      permission.external_directory = "allow";
    };
  };
}
