# mpvpaper — Video wallpaper utility for Wayland using mpv.
{ lib, pkgs, ... }:

let
  version = "1.1.0";
  rev = "v1.1.0";
  src = pkgs.fetchFromGitHub {
    owner = "GhostNaN";
    repo = "mpvpaper";
    inherit rev;
    hash = lib.fakeHash; # TODO: replace with real hash
  };
in
pkgs.stdenv.mkDerivation {
  pname = "mpvpaper";
  inherit version src;

  nativeBuildInputs = with pkgs; [ meson ninja pkg-config ];

  buildInputs = with pkgs; [
    mpv
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
    ffmpeg
  ];

  mesonFlags = [
    "-Dbuildtype=release"
    "-Db_ndebug=true"
  ];

  meta = with lib; {
    description = "Video wallpaper utility for Wayland using mpv";
    homepage = "https://github.com/GhostNaN/mpvpaper";
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
