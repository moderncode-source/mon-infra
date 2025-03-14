# Local environment configuration files.
# Can be used together with Direnv to quickly activate your development
# environment. For more complex scenarios, use `flake.nix`.
{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  packages = import ./nix/dependencies.nix pkgs;
}
