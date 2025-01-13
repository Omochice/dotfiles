{
  description = "Flake for the FirgeNerd programming font";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "FirgeNerd";
          version = "0.3.0";

          src = pkgs.fetchzip {
            url = "https://github.com/yuru7/Firge/releases/download/v${version}/${pname}_v${version}.zip";
            hash = "sha256-Zb95RroGitkOetmLPa4r8EsIKnKiYw7pAlVg6j9lgoc=";
          };

          installPhase = ''
            runHook preInstall
            install -Dm644 *.ttf -t $out/share/fonts/FirgeNerd
            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Programming font that combines Genshin Gothic and Fira Mono with Nerd Font";
            homepage = "https://github.com/yuru7/Firge";
            license = licenses.ofl;
            platforms = platforms.all;
          };
        };
      }
    );
}
