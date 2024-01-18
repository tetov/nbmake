{
  description = "nbmake packaged using poetry2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    poetry2nix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgName = "nbmake";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      stdenv = pkgs.stdenv;
      inherit
        (poetry2nix.lib.mkPoetry2Nix {inherit pkgs;})
        mkPoetryApplication
        defaultPoetryOverrides
        ;
    in {
      packages = {
        ${pkgName} = mkPoetryApplication {
          projectDir = self;
          overrides = defaultPoetryOverrides.extend (self: super: {
            # remove rpds-py override when this PR is merged
            # https://github.com/nix-community/poetry2nix/pull/1507
            rpds-py = let
              getCargoHash = version:
                {
                  "0.8.8" = "sha256-jg9oos4wqewIHe31c3DixIp6fssk742kqt4taWyOq4U=";
                  "0.8.10" = "sha256-D4pbEipVn1r5rrX+wDXi97nDZJyBlkdqhmbJSgQGTLU=";
                  "0.8.11" = "sha256-QZNm/b9s/qr3GHwe9wG7U9/AaQwSPHsQ0F2SFQdgPNo=";
                  "0.8.12" = "sha256-wywBytnfLBnBH2yYi2eLQjASDmFN9VqPABwMuSUxN0Q=";
                  "0.9.2" = "sha256-2LiQ+beFj9+kykObPNtqcg+F+8wBDzvWcauwDLHa7Yo=";
                  "0.10.0" = "sha256-FXjk1Y/Eol4d1xvwz0S42OycZV0cSHM36H+zjEmNPCQ=";
                  "0.10.2" = "sha256-X0Busta5y1ToLcF6/5ZiatP8m/nxFsVGW/ba0MS4hhg=";
                  "0.10.3" = "sha256-iWy6BHVsKsZB0SVrh3CVhryaavk4gAQVvRdu9xBiDRg=";
                  "0.10.4" = "sha256-JOzc6rB65oNhQqjuDNeSgRhvXg2fQDf5ogoYznaBj5Y=";
                  "0.10.5" = "sha256-WB1PaJod7Romvme+lcTR6lh9CAbg+67ptBj838b3KFc=";
                  "0.10.6" = "sha256-8bXCTrZErdE7JhuoudU/4dDndCMwvjy2a+2IY0DWDzg=";
                  "0.11.0" = "sha256-4q/m+8UKAH7q7Jr95vvpU/me0pzvYTivcFA+unfOeQ8=";
                  "0.12.0" = "sha256-jdr0xN3Pd/bCoKfLLFNGXHJ+G1ORAft6/W7VS3PbdHs=";
                  "0.13.0" = "sha256-bHfxiBSN7/SbZiyYRj01phwrpyH7Fa3xVaA3ceWZYCE=";
                  "0.13.1" = "sha256-Q6TNWCJYlHnka4N+Q2OcqSe1h066X9CZK9pUFxxUgrI=";
                  "0.13.2" = "sha256-jaLSrl0oT3Fo/F0FfLvA2wDJk/Fc3d7mBqwRqyWAOsg=";
                  "0.14.0" = "sha256-CXEmCxntkBI06JMBE4D5FD9GoWqq99d1xHBG/KOURL4=";
                  "0.14.1" = "sha256-5CKH+bbU0DGIw6v1/AsnGxsD7TidJ55lQHQuVSgbYTo=";
                  "0.14.2" = "sha256-bWFUuoi/IgIrC/g9TwDAiMvpPKe6+r/xdLf2GZIhMyE=";
                  "0.15.0" = "sha256-jFpRXcLBZJ2ZFiV3TDN4qrAi2IcJEKcPnOlU6txXqoU=";
                  "0.15.1" = "sha256-OAkKmSHhKwLkx77I7lSmJyjchIt1kAgGISfIWiqPkM8=";
                  "0.15.2" = "sha256-4hkJ39jN2V74/eJ/MQmLAx8s0DnQTfsdN1bU4Fvfiq4=";
                  "0.16.0" = "sha256-I1F9BS+0pQ7kufcK5dxfHj0LrVR8r8xM6k8mtf7emZ4=";
                  "0.16.1" = "sha256-aSXLPkRGrvyp5mLDnG2D8ZPgG9a3fX+g1KVisNtRadc=";
                  "0.16.2" = "sha256-aPmi/5UAkePf4nC2zRjXY+vZsAsiRZqTHyZZmzFHcqE=";
                  "0.17.1" = "sha256-sFutrKLa2ISxtUN7hmw2P02nl4SM6Hn4yj1kkXrNWmI=";
                }
                .${version}
                or (
                  lib.warn "Unknown rpds-py version: '${version}'. Please update getCargoHash." lib.fakeHash
                );
            in
              super.rpds-py.overridePythonAttrs (old:
                lib.optionalAttrs (!(old.src.isWheel or false)) {
                  cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
                    inherit (old) src;
                    name = "${old.pname}-${old.version}";
                    hash = getCargoHash old.version;
                  };
                  buildInputs =
                    (old.buildInputs or [])
                    ++ lib.optionals stdenv.isDarwin [
                      pkgs.libiconv
                    ];
                  nativeBuildInputs =
                    (old.nativeBuildInputs or [])
                    ++ [
                      pkgs.rustPlatform.cargoSetupHook
                      pkgs.rustPlatform.maturinBuildHook
                    ];
                });
          });
        };

        default = self.packages.${system}.${pkgName};
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [self.packages.${system}.${pkgName}];
        packages = [pkgs.poetry];
      };

      formatter = pkgs.alejandra;
    });
}
