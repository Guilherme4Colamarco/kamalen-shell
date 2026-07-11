# gpu-screen-recorder — GPU-accelerated screen recorder for Wayland.
{ lib, pkgs, ... }:

let
  version = "0.1.0";
  rev = "main";
  src = pkgs.fetchFromGitHub {
    owner = "wlrfx";
    repo = "gpu-screen-recorder";
    inherit rev;
    hash = lib.fakeHash; # TODO: replace with real hash
  };
in
pkgs.stdenv.mkDerivation {
  pname = "gpu-screen-recorder";
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
    ffmpeg
    libva
    libvdpau
    vulkan-headers
    vulkan-loader
    mesa
    pipewire
    gtk3
    libnotify
  ];

  mesonFlags = [
    "-Dbuildtype=release"
    "-Db_ndebug=true"
    "-Dgtk=enabled"
    "-Dsystemd=enabled"
  ];

  meta = with lib; {
    description = "GPU-accelerated screen recorder for Wayland";
    homepage = "https://git.dec05eba.com/gpu-screen-recorder";
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
