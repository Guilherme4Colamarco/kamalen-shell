# kamalen-python — Kamalen Shell Python utilities.
#
# Bundles:
#   - iris.py (color extraction from wallpapers)
#   - mango_config.py (MangoWM config CLI)
#   - dbus-notifier.py (notification daemon for QuickShell)
#   - wallhaven.py (Wallhaven API client)
{ lib, pkgs, ... }:

let
  version = "1.0.0";
  # Source: the kamalen-shell repo root (two levels up from pkgs/kamalen-python/)
  srcRoot = ./../..;
in
pkgs.python3Packages.buildPythonApplication {
  pname = "kamalen-python";
  inherit version;
  src = srcRoot;

  propagatedBuildInputs = with pkgs.python3Packages; [
    pillow
    numpy
    pam
    requests
  ];

  # Install scripts to $out/bin with convenient names.
  postInstall = ''
    mkdir -p $out/bin
    mkdir -p $out/share/kamalen-python

    # iris.py — color extraction
    cp $src/.config/quickshell/iris/iris.py $out/share/kamalen-python/iris.py
    chmod +x $out/share/kamalen-python/iris.py
    ln -s $out/share/kamalen-python/iris.py $out/bin/kamalen-iris

    # mango_config.py — MangoWM config CLI
    cp $src/.config/mango/mango_config.py $out/share/kamalen-python/mango_config.py
    chmod +x $out/share/kamalen-python/mango_config.py
    ln -s $out/share/kamalen-python/mango_config.py $out/bin/kamalen-mango-config

    # dbus-notifier.py — notification daemon
    cp $src/.config/quickshell/dbus-notifier.py $out/share/kamalen-python/dbus-notifier.py
    chmod +x $out/share/kamalen-python/dbus-notifier.py
    ln -s $out/share/kamalen-python/dbus-notifier.py $out/bin/kamalen-dbus-notifier

    # wallhaven.py — Wallhaven API client
    cp $src/.config/quickshell/wallhaven/wallhaven.py $out/share/kamalen-python/wallhaven.py
    chmod +x $out/share/kamalen-python/wallhaven.py
    ln -s $out/share/kamalen-python/wallhaven.py $out/bin/kamalen-wallhaven
  '';

  meta = with lib; {
    description = "Kamalen Shell Python utilities (iris, mango-config, dbus-notifier, wallhaven)";
    homepage = "https://github.com/Guilherme4Colamarco/kamalen-shell";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
