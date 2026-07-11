#!/usr/bin/env bash
# Test script for Kamalen Shell NixOS port.
#
# Run from the flake directory:
#   ./test-flake.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

log()    { echo -e "${GREEN}[OK]${RESET} $*"; }
warn()   { echo -e "${YELLOW}[!]${RESET} $*"; }
error()  { echo -e "${RED}[FAIL]${RESET} $*"; }
info()   { echo -e "${BLUE}[i]${RESET} $*"; }

cd "$FLAKE_DIR"

info "Testing Kamalen Shell NixOS port..."
echo ""

# ── 1. Check flake validity ─────────────────────────────────────────────
info "Checking flake validity..."
if nix flake check --no-build 2>&1 | tail -20; then
    log "Flake check passed"
else
    warn "Flake check had issues (expected with fake hashes)"
fi
echo ""

# ── 2. Show available outputs ────────────────────────────────────────────
info "Available flake outputs:"
nix flake show 2>&1 | head -40
echo ""

# ── 3. Build devShell ────────────────────────────────────────────────────
info "Building devShell..."
if nix build .#devShells.x86_64-linux.default --no-link 2>&1 | tail -10; then
    log "devShell builds successfully"
else
    warn "devShell build failed"
fi
echo ""

# ── 4. Build individual packages ─────────────────────────────────────────
PACKAGES=(
    "mango-ext"
    "awww"
    "mpvpaper"
    "rmpc"
    "tiramisu"
    "gpu-screen-recorder"
    "pokemon-colorscripts"
    "kamalen-python"
)

info "Building packages (will fail with fake hashes until updated)..."
for pkg in "${PACKAGES[@]}"; do
    info "Building $pkg..."
    if nix build ".#${pkg}" --no-link 2>&1 | tail -5; then
        log "$pkg builds"
    else
        warn "$pkg failed (expected with fake hashes — read the error for the correct hash)"
    fi
done
echo ""

# ── 5. Test NixOS configuration (dry-run) ────────────────────────────────
info "Testing NixOS configuration (dry-run)..."
if nix build ".#nixosConfigurations.kamalen-test.config.system.build.toplevel" --dry-run 2>&1 | tail -10; then
    log "NixOS config evaluates"
else
    warn "NixOS config evaluation failed (expected without real hashes)"
fi
echo ""

# ── 6. Test Home Manager configuration (dry-run) ─────────────────────────
info "Testing Home Manager configuration (dry-run)..."
if nix build ".#homeConfigurations.geko.activationPackage" --dry-run 2>&1 | tail -10; then
    log "Home Manager config evaluates"
else
    warn "Home Manager config evaluation failed (expected without real hashes)"
fi
echo ""

log "Test script completed!"
echo ""
info "Next steps:"
echo "  1. Replace lib.fakeHash with real hashes in pkgs/*/default.nix"
echo "     (build each package and copy the hash from the error message)"
echo "  2. Run: nix flake check"
echo "  3. Test in VM: nix build .#nixosConfigurations.kamalen-test.config.system.build.vm"
echo "  4. Deploy to real hardware (replace hardware-configuration.nix)"
