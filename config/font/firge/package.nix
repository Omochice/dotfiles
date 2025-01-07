{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "Firge";
  version = "0.3.0";

  src = fetchzip {
    url = "https://github.com/yuru7/Firge/releases/download/v${version}/${pname}_v${version}.zip";
    hash = "sha256-zPAeOits3FxIwerGCY8L3eDZtBi3qU19p3XOhtcMV64=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 *.ttf -t $out/share/fonts/Firge
    runHook postInstall
  '';

  meta = with lib; {
    description = "Programming font that combines Genshin Gothic and Fira Mono";
    homepage = "https://github.com/yuru7/Firge";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
