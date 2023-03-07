{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    utils,
    ...
  }:
    utils.lib.eachDefaultSystem (
      system: let
        packageName = "fp-course";
        config = {};

        overlay = pkgsNew: pkgsOld: {
          ${packageName} =
            pkgsNew.haskell.lib.justStaticExecutables
            pkgsNew.haskellPackages.${packageName};

          haskellPackages = pkgsOld.haskellPackages.override (old: {
            overrides = pkgsNew.haskell.lib.packageSourceOverrides {
              ${packageName} = ./.;
            };
          });
        };

        pkgs = import nixpkgs {
          inherit config system;
          overlays = [overlay];
        };
      in {
        packages.default = pkgs.haskellPackages.${packageName};

        devShells.default = pkgs.haskellPackages.shellFor {
          packages = p: [p.${packageName}];
          buildInputs = with pkgs; [
            alejandra
            haskellPackages.ghcid
            haskellPackages.haskell-language-server
            pre-commit
          ];
          shellHook = ''
            pre-commit install
          '';
        };
      }
    );
}
