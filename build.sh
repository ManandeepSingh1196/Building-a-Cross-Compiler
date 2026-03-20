#

#!/usr/bin/env bash
set -euo pipefail

# VARIABLES

TARGET="x86_64-elf"
PREFIX="$HOME/opt/cross"
SRCDIR="$HOME/src/cross-toolchain"
$PKG_MGR="pacman"

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
        die "Missing: ${missing[*]}\nRun: sudo $PKG_MGR -S base-devel gmp mpc libmpc mpfr"
    
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

# BUILDING BINUTILS
build_binutils()
{
    info "Building binutils ${BINUTILS_VER}.. "
    cd "${SRCDIR}"
    
    sudo rm -rf build-binutils 
    mkdir build-binutils && cd build-binutils

    ../binutils-${BINUTILS_VER}/configure \
        --prefix=$PREFIX    \
        --target=$TARGET    \
        --with-sysroot      \
        --disable-nls       \
        --disable-werror    \
        --quiet

    make -j$(nproc)
    make install

    success "binutils built."
}

# BUILDING GCC
build_gcc() 
{
    info "Building GCC ${GCC_VER}. This might take some time.. "
    export PATH="$PREFIX/bin:$PATH"
    cd "$SRCDIR"

    sudo rm -rf build-gcc
    mkdir build-gcc && cd build-gcc

    ../gcc-${GCC_VER}/configure     \
        --prefix=$PREFIX            \
        --target=$TARGET            \
        --disable-nls               \
        --without-headers           \
        --enable-languages=c,c++    \
        --quiet

    make -j$(nproc) all-gcc
    make -j$(nproc) all-target-libgcc

    make install-gcc
    make install-target-libgcc

    success "GCC built."
}

# VERIFYING
verify() 
{
    info "Verifying..."
    export PATH="$PREFIX/bin:$PATH"

    "${TARGET}-gcc" --version &>/dev/null || die "${TARGET}-gcc not found."
    "${TARGET}-ld"  --version &>/dev/null || die "${TARGET}-ld not found."

    success "${TARGET}-gcc: $("${TARGET}-gcc" --version | head -1)"
    success "${TARGET}-ld:  $("${TARGET}-ld"  --version | head -1)"

    echo ""
    echo "Add to your .bashrc / .zshrc:"
    echo "  export PATH=\"$PREFIX/bin:\$PATH\""
}

# MAIN 
main ()
{
    info "Build script for a x86_64-elf cross compiler."
    info "binutils ${BINUTILS_VER} | GCC ${GCC_VER} | prefix:$PREFIX"

    check_deps
    download_sources
    build_binutils
    build_gcc
    verify
}

main "$@"
