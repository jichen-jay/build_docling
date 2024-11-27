let
  pkgs = import <nixpkgs> { dockerTools };
  dockerTools = pkgs.dockerTools;
in
dockerTools.buildNixShellImage {
  drv = pkgs.hello;
  tag = "latest";
}