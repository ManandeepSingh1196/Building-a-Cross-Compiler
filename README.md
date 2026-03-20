# x86_64-elf Cross Compiler

Automated build scripts for an `x86_64-elf` cross-compiler toolchain (binutils + GCC) targeting bare-metal x86_64 development. Intended for OS and kernel development where you need a compiler that produces ELF binaries without any host system dependencies.

---

## What it builds

| Component | Default Version |
|-----------|----------------|
| binutils  | 2.46.0         |
| GCC       | 15.2.0         |

Installed to `~/opt/cross`. Binaries are prefixed with `x86_64-elf-` (e.g. `x86_64-elf-gcc`, `x86_64-elf-ld`).

---

## Requirements

Linux. The following must be present before building:

```
base-devel   gcc   g++   make   wget   tar   bison   flex
gmp   libmpc   mpfr
```

Install everything in one shot:
```bash
sudo pacman -S base-devel gmp libmpc mpfr
```

---

## Usage

### Build

```bash
bash build.sh
```

Runs dependency checks, downloads sources, builds binutils then GCC, and verifies the output.

**Override versions without editing the script:**
```bash
BINUTILS_VER=2.46.0 GCC_VER=15.2.0 PKG_MGR=pacman bash build.sh
```

Once built, add the toolchain to your PATH:
```bash
export PATH="$HOME/opt/cross/bin:$PATH"
```

Add that line to your `.bashrc` or `.zshrc` to persist it.

### Clean

```bash
bash clean.sh
```

Removes everything the build script created — build artifacts, downloaded tarballs, extracted source directories, and the installed toolchain from `~/opt/cross`. Prompts for confirmation before deleting anything.

---

## Directory layout

```
~/src/cross-toolchain/          # sources and build dirs (SRCDIR)
    binutils-<ver>.tar.xz
    gcc-<ver>.tar.xz
    binutils-<ver>/             # extracted source
    gcc-<ver>/                  # extracted source
    build-binutils/             # out-of-tree build
    build-gcc/                  # out-of-tree build

~/opt/cross/                    # installed toolchain (PREFIX)
    bin/
        x86_64-elf-gcc
        x86_64-elf-ld
        ...
    lib/gcc/x86_64-elf/
    libexec/gcc/x86_64-elf/
    x86_64-elf/
```

---

## Files

| File | Purpose |
|------|---------|
| `build.sh` | Builds and installs the cross-compiler |
| `clean.sh` | Removes everything installed by `build.sh` |
