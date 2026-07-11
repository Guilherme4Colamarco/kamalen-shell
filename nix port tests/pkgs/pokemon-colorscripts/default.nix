# pokemon-colorscripts — Pokemon terminal art colorscripts.
{ lib, pkgs, ... }:

let
  version = "1.0.0";
  rev = "main";
  src = pkgs.fetchFromGitLab {
    owner = "phoneybadner";
    repo = "pokemon-colorscripts";
    inherit rev;
    hash = lib.fakeHash; # TODO: replace with real hash
  };
in
pkgs.stdenv.mkDerivation {
  pname = "pokemon-colorscripts";
  inherit version src;

  nativeBuildInputs = [ ];

  buildInputs = with pkgs; [ bash coreutils ];

  # No build system — just install scripts.
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/share/pokemon-colorscripts
    cp -r pokemon-colorscripts.sh $out/bin/pokemon-colorscripts
    cp -r colorscripts $out/share/pokemon-colorscripts/
    chmod +x $out/bin/pokemon-colorscripts
    runHook postInstall
  '';

  meta = with lib; {
    description = "Pokemon colorscripts for terminal";
    homepage = "https://gitlab.com/phoneybadner/pokemon-colorscripts";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
