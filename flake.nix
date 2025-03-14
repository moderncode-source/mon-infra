{
  description = "Flake for developing monitoring infastructure";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    systems.url = "github:nix-systems/default-linux";
  };

  outputs = {
    nixpkgs,
    systems,
    ...
  }: let
    inherit (nixpkgs) lib;
    eachSystem = lib.genAttrs (import systems);

    pkgsFor = eachSystem (system:
      import nixpkgs {
        localSystem = system;
      });
  in {
    devShells = eachSystem (system: let
        # Build manifest files for all of the project's libraries and packages.
        # The exact steps taken are specified in `manifests.build` shell
        # scripts for each such library or package. This Nix package will find
        # and run them.
        build-manifests =
          pkgsFor.${system}.callPackage
          ./nix/build-manifests.nix {};
      in rec
      {
        default = dev;

        # A complete shell with all required packages to develop the
        # project and execute an entire CI/CD chain for it.
        dev =
          pkgsFor.${system}.mkShell
          {
            name = "dev-shell";
            packages = import ./nix/dependencies.nix pkgsFor.${system};
            buildInputs = [
              build-manifests
            ];
          };
      });

    # Format Nix code and check for styling rules using the `nix fmt`.
    formatter = eachSystem (
      system:
        pkgsFor.${system}.callPackage
        ./nix/formatter.nix {
        }
    );
  };
}
