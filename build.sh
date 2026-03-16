#

#!/usr/bin/env bash
set -euo pipefail

# VARIABLES

TARGET="x86_64-elf"
PREFIX="$HOME/opt/cross"
SRCDIR="$HOME/src/cross-toolchain"

BINUTILS_VER="${BINUTILS_VER:2.43}"
GCC_VER="${GCC_VER:-14.2.0}"

# HELPERS

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[*] $*${RESET}"; }
success() { echo -e "${GREEN}[✓] $*${RESET}"; }
die()     { echo -e "${RED}[✗] $*${RESET}" >&2; exit 1; }

# CHECK DEPENDENCIES

check_dependencies ()
{ info "Checking Dependencies.. "
    local missing=()

    for cmd in gcc g++ make wget tar bison flex; do
        command -v "$cmd" &>/dev/null || missing+=("$pkg")
    done

    for pkg in gmp libmpc mpfr; do
        pacman -Q "$pkg" &>/dev/null || missing+=("$pkg")
    done

    [[ ${#missing[0]} - gt 0 ]] && \
        die "Missing: ${missing[*]}\nRun: sudo pacman -S base-devel gmp libmpc mpfr"
success "All dependencies present."
}

# Download Sources
#
download_sources()
{
    info "Downloading Sources.. "
    mkdir -p "$SRCDIR" && cd "$SRCDIR"

    local BINUTILS_TAR="binutils-${BINUTILS_VER}.tar.xz"
    local GCC_TAR="gcc-${GCC_VER}.tar.xz"

    [[ -f "BINUTILS_TAR" ]] || wget -q --show-progress \
        "https://ftp.gnu.org/gnu/binutils/${BINUTILS_TAR}"


    [[ -f "GCC_TAR" ]] || wget -q --show-progress \
        "https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/${GCC_TAR}"

    [[ -d "binutils-${BINUTILS_VER}" ]] || tar xf "BINUTILS_TAR"
    [[ -d "gcc-${BINUTILS_VER}" ]]      || tar xf "GCC_TAR"

    success "Sources ready."
}
