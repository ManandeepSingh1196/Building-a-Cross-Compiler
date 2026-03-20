#!/usr/bin/env bash
set -euo pipefail

# VARIABLES
TARGET="x86_64-elf"
PREFIX="$HOME/opt/cross"
SRCDIR="$HOME/src/cross-toolchain"

BINUTILS_VER="${BINUTILS_VER:-2.46.0}"
GCC_VER="${GCC_VER:-15.2.0}"

# HELPERS
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; RESET='\033[0m'

info()      { echo -e "[*] $*${RESET}"; }
success()   { echo -e "${GREEN}[OK] $*${RESET}"; }
die()       { echo -e "${RED}[FAIL] $*${RESET}" >&2; exit 1; }

# REMOVE
remove()
{
    local target="$1"

    if [[ ! -e "$target" ]]; then
        info "Error: Not found, skipping $target"
        return
    fi

    rm -rf "$target"
    success "Removed: $target"
}

# CLEANUP
clean_artifacts()
{
    info "Removing build artifacts.. "
    
    remove "${SRCDIR}/build-binutils"
    remove "${SRCDIR}/build-gcc"

    success "Build artifacts cleaned."
}

clean_source()
{
    info "Removing source directories.. "
    remove "${SRCDIR}/binutils-${BINUTILS_VER}"
    remove "${SRCDIR}/gcc-${GCC_VER}"
    success "Removed source directories.. "

    info "Removing tarballs.. "
    remove "${SRCDIR}/binutils-${BINUTILS_VER}.tar.xz"
    remove "${SRCDIR}/gcc-${GCC_VER}.tar.xz"
    success "Removed tarballs."

    #if SRCDIR is empty, then remove it
    if [[ -d "$SRCDIR" ]] && [[ -z "$(ls -A "$SRCDIR")" ]]; then
        remove "$SRCDIR"
    fi

    success "Sources cleaned."
}

clean_prefix()
{
    info "Removing installed ${TARGET} toolchain from ${PREFIX}.."

    local bins=("${PREFIX}/bin/${TARGET}-"*)
    if [[ -e "${bins[0]}" ]]; then
        rm -f "${PREFIX}/bin/${TARGET}-"*
        success "Removed: ${PREFIX}/bin/${TARGET}-*"
    else
        info "Not found, skipping: ${PREFIX}/bin/${TARGET}-*"
    fi

    remove "${PREFIX}/lib/gcc/${TARGET}"
    remove "${PREFIX}/libexec/gcc/${TARGET}"
    remove "${PREFIX}/${TARGET}"

    # prune empty parent dirs
    for dir in "${PREFIX}/lib/gcc" "${PREFIX}/libexec/gcc" \
               "${PREFIX}/lib"     "${PREFIX}/libexec"; do
        if [[ -d "$dir" ]] && [[ -z "$(ls -A "$dir")" ]]; then
            remove "$dir"
        fi
    done

    # remove prefix itself if now empty
    if [[ -d "$PREFIX" ]] && [[ -z "$(ls -A "$PREFIX")" ]]; then
        remove "$PREFIX"
    fi

    success "Prefix cleaned."
}

# CONFIRM
confirm()
{
    echo ""
    info "The following will be removed:"
    echo ""

    echo "  Build artifacts:"
    echo "    ${SRCDIR}/build-binutils"
    echo "    ${SRCDIR}/build-gcc"
    echo ""

    echo "  Source directories:"
    echo "    ${SRCDIR}/binutils-${BINUTILS_VER}"
    echo "    ${SRCDIR}/gcc-${GCC_VER}"
    echo ""

    echo "  Tarballs:"
    echo "    ${SRCDIR}/binutils-${BINUTILS_VER}.tar.xz"
    echo "    ${SRCDIR}/gcc-${GCC_VER}.tar.xz"
    echo ""

    echo "  Installed files under ${PREFIX}:"
    echo "    ${PREFIX}/bin/${TARGET}-*"
    echo "    ${PREFIX}/lib/gcc/${TARGET}"
    echo "    ${PREFIX}/libexec/gcc/${TARGET}"
    echo "    ${PREFIX}/${TARGET}"
    echo ""

    read -r -p "Proceed? [y/N] " response
    [[ "$response" =~ ^[Yy]$ ]] || die "Cancelled."
}

# MAIN
main()
{
    info "Cleanup script for ${TARGET} cross-compiler."
    info "binutils ${BINUTILS_VER} | GCC ${GCC_VER} | prefix:$PREFIX"

    confirm 
    clean_artifacts
    clean_source
    clean_prefix

    echo ""
    success "Cleaning complete."
}

main "$@"
