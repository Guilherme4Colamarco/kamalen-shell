# Library helpers for the Kamalen Shell flake.
#
# These are utility functions that can be used by other parts of the flake
# or by consumers. They are not required for the core functionality.
{ nixpkgs, lib ? nixpkgs.lib, ... }:

{
  # Create a simple derivation that wraps a shell script as an executable.
  makeScript =
    { name
    , script
    , dependencies ? [ ]
    , ...
    } @ attrs:
    nixpkgs.stdenv.mkDerivation (attrs // {
      pname = name;
      version = "1.0.0";
      # Empty source — we only write the script in installPhase.
      dontUnpack = true;
      nativeBuildInputs = dependencies;
      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cat > $out/bin/${name} << 'SCRIPT'
        ${script}
        SCRIPT
        chmod +x $out/bin/${name}
        runHook postInstall
      '';
    });

  # Fetch from GitHub with hash verification.
  # Use lib.fakeHash during development; Nix will report the correct hash.
  fetchGitHubChecked = { owner, repo, rev, hash ? lib.fakeHash, ... }:
    nixpkgs.fetchFromGitHub { inherit owner repo rev hash; };

  # Fetch from GitLab with hash verification.
  fetchGitLabChecked = { owner, repo, rev, hash ? lib.fakeHash, ... }:
    nixpkgs.fetchFromGitLab { inherit owner repo rev hash; };

  # Create a Python package from local script files.
  # `scripts` is a list of attrsets: { src = relative/path.py; dest = "name.py"; binName = "cli-name"; }
  makePythonPackage =
    { name
    , version
    , srcRoot
    , scripts
    , dependencies ? [ ]
    , ...
    } @ attrs:
    nixpkgs.python3Packages.buildPythonApplication (attrs // {
      pname = name;
      inherit version;
      src = srcRoot;
      postInstall = ''
        mkdir -p $out/bin
        mkdir -p $out/share/${name}
        ${lib.concatStringsSep "\n" (builtins.map (s: ''
          cp $src/${s.src} $out/share/${name}/${s.dest}
          chmod +x $out/share/${name}/${s.dest}
          ln -s $out/share/${name}/${s.dest} $out/bin/${s.binName}
        '') scripts)}
      '';
      propagatedBuildInputs = dependencies;
    });

  # Create a systemd user service attrset for home-manager.
  makeUserService =
    { name
    , description
    , execStart
    , wantedBy ? [ "graphical-session.target" ]
    , after ? [ ]
    , environment ? { }
    , restart ? "on-failure"
    , restartSec ? 5
    }:
    {
      inherit description wantedBy after;
      serviceConfig = {
        ExecStart = execStart;
        Restart = restart;
        RestartSec = toString restartSec;
      };
      environment = environment;
    };

  # Create a home.file entry attrset.
  makeHomeFile =
    { source ? null
    , target
    , recursive ? false
    , executable ? false
    , text ? null
    }:
    if text != null then
      { inherit text executable; }
    else
      { inherit source target recursive executable; };

  # Create an xdg.configFile entry attrset.
  makeXdgConfig =
    { source
    , target
    , recursive ? true
    }:
    { inherit source target recursive; };
}
