# tiramisu — Notification daemon for Wayland.
{ lib, pkgs, ... }:

let
  version = "0.1.0";
  rev = "main";
  src = pkgs.fetchFromGitHub {
    owner = "Scrumplex";
    repo = "tiramisu";
    inherit rev;
    hash = lib.fakeHash; # TODO: replace with real hash
  };
in
pkgs.stdenv.mkDerivation {
  pname = "tiramisu";
  inherit version src;

  nativeBuildInputs = with pkgs; [ meson ninja pkg-config ];

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
    libnotify
    gtk3
  ];

  mesonFlags = [
    "-Dbuildtype=release"
    "-Db_ndebug=true"
  ];

  meta = with lib; {
    description = "Notification daemon for Wayland";
    homepage = "https://github.com/Scrumplex/tiramisu";
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
