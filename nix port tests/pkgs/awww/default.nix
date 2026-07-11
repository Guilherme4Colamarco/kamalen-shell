# awww — Wayland wallpaper daemon with transitions.
{ lib, pkgs, ... }:

let
  version = "0.3.0";
  rev = "v0.3.0";
  src = pkgs.fetchFromGitHub {
    owner = "LGFae";
    repo = "awww";
    inherit rev;
    hash = lib.fakeHash; # TODO: replace with real hash
  };
in
pkgs.stdenv.mkDerivation {
  pname = "awww";
  inherit version src;

  nativeBuildInputs = with pkgs; [ pkg-config ];

  buildInputs = with pkgs; [
    wayland
    wayland-protocols
    libdrm
    libxkbcommon
    libinput
    pixman
    libglvnd
    seatd
    libdisplay-info
    libliftoff
    hwdata
    cairo
    pango
    glib
    dbus
    systemd
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Wayland wallpaper daemon with transitions";
    homepage = "https://codeberg.org/LGFae/awww";
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
