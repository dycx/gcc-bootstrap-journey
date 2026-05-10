# GCC Modern: 5.x to Present (2015-2026)

## Version Numbering Change (GCC 5.0, 2015)

Before GCC 5, version numbers were: 4.0, 4.1, ..., 4.9
After GCC 5, they changed to: 5, 6, 7, 8, 9, 10, 11, 12, 13, 14

The major version number now increments每年 (yearly).

## Modern GCC Architecture (GCC 14)

```
Source Code (.c, .cpp, .f90, .rs, .d, .go, .jit)
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│  Front-Ends (language-specific parsers)                 │
│  - cc1      (C)                                         │
│  - cc1plus  (C++)                                       │
│  - f951     (Fortran)                                   │
│  - go1      (Go)                                        │
│  - d21      (D)                                         │
│  - lto1     (Link-Time Optimization)                    │
│                                                         │
│  Output: GENERIC trees                                  │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  Middle-End (language-independent optimizations)        │
│                                                         │
│  1. GENERIC → GIMPLE lowering                          │
│  2. SSA Construction                                   │
│  3. Tree SSA Passes (in order):                        │
│     - CCP (Conditional Constant Propagation)            │
│     - Copy Propagation                                  │
│     - DCE (Dead Code Elimination)                       │
│     - DOM (Dominator Optimizations)                     │
│     - PRE (Partial Redundancy Elimination)              │
│     - FRE (Full Redundancy Elimination)                 │
│     - VRP (Value Range Propagation)                     │
│     - Thread Jumps                                      │
│     - PHI node elimination                              │
│  4. Loop Optimizations:                                 │
│     - Loop invariant code motion                        │
│     - Loop unrolling/unrolling                          │
│     - Loop vectorization                                │
│     - Loop interchange                                  │
│  5. IPA (Interprocedural Analysis):                     │
│     - Inlining decisions                                │
│     - Devirtualization                                   │
│     - Constant propagation across functions              │
│  6. Out of SSA → lower GIMPLE                          │
│  7. RTL Generation                                      │
│                                                         │
│  Output: RTL (Register Transfer Language)               │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  Back-End (target-specific code generation)             │
│                                                         │
│  1. RTL Optimization passes:                            │
│     - Register allocation (IRA + LRA)                   │
│     - Instruction scheduling                            │
│     - Peephole optimization                             │
│     - Delay branch scheduling                           │
│  2. Assembly generation                                 │
│  3. DWARF debug info generation                         │
│                                                         │
│  Output: Assembly (.s)                                  │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  Assembler (system as / gas)                            │
│  Output: Object files (.o)                              │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│  Linker (system ld / gold / lld)                        │
│  Output: Executable / Shared library                    │
└─────────────────────────────────────────────────────────┘
```

## Modern Bootstrap Process (GCC 14.2)

### Prerequisites

```bash
# System packages needed
sudo apt install build-essential g++ \
    libgmp-dev libmpfr-dev libmpc-dev libisl-dev \
    flex bison texinfo autogen autoconf automake \
    zlib1g-dev

# Or use the built-in downloader
cd gcc-14.2.0
./contrib/download_prerequisites
```

### Standard 3-Stage Bootstrap

```bash
# Download
wget https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz
tar xf gcc-14.2.0.tar.xz
cd gcc-14.2.0

# Download GMP, MPFR, MPC, ISL
./contrib/download_prerequisites

# Out-of-tree build (REQUIRED for modern GCC)
mkdir objdir && cd objdir

# Configure
../gcc-14.2.0/configure \
    --prefix=/usr/local \
    --enable-languages=c,c++ \
    --disable-multilib \
    --enable-bootstrap \
    --disable-libsanitizer \
    --disable-libvtv

# 3-stage bootstrap (this takes a LONG time)
make -j$(nproc) bootstrap

# Install
sudo make install
```

### What `make bootstrap` Does (Modern)

```bash
# Equivalent to:
make all-gcc                    # Build stage1 compiler
make all-gcc stage=stage2       # Build stage2 compiler  
make all-gcc stage=stage3       # Build stage3 compiler
make compare                    # Compare stage2 vs stage3
make install-gcc                # Install stage3 compiler
```

### Profiled Bootstrap (PGO)

```bash
make -j$(nproc) profiledbootstrap
```

This does a 4-stage process:
1. Stage 1: Build with system compiler
2. Stage 2: Build with Stage 1, instrumented for profiling
3. Run Stage 2 compiler on test suite to collect profile data
4. Stage 3: Build with Stage 1 compiler + profile data

Result: A compiler that's 5-15% faster at compiling real code.

## Modern GCC Features

### Languages Supported
- C, C++ (primary)
- Fortran
- Go
- D
- Ada (GNAT)
- Modula-2
- Rust (experimental, added GCC 13)

### Optimization Levels
```
-O0    No optimization (default for debugging)
-O1    Basic optimizations
-O2    Standard optimizations (recommended)
-O3    Aggressive optimizations (may increase code size)
-Os    Size optimization
-Og    Optimizations that don't interfere with debugging
-Ofast -O3 + fast-math (may break IEEE compliance)
-Oz    Aggressive size optimization
```

### Key Modern Features
1. **Link-Time Optimization (LTO)**: Optimizes across translation units
2. **Auto-vectorization**: Automatic SIMD (SSE/AVX/NEON)
3. **Profile-Guided Optimization (PGO)**: Use runtime profiles to guide optimization
4. **Sanitizers**: AddressSanitizer, ThreadSanitizer, UBSanitizer
5. **Fortran 2018/2023**: Modern Fortran support
6. **C++23**: Full C++23 standard support
7. **OpenMP 5.x**: Parallel programming support

## Current Bootstrap Chain

The modern GCC bootstrap chain:

```
System C++ compiler (g++ or clang++)
    │
    ▼
Stage 1: GCC compiled by system compiler
    │
    ▼
Stage 2: GCC compiled by Stage 1 GCC
    │
    ▼
Stage 3: GCC compiled by Stage 2 GCC
    │
    ▼
Compare: Stage 2 == Stage 3?
    │
    ▼
Install: Stage 3 is the "true" GCC
```

## Summary

Modern GCC (14.x) is:
- Written in C++ (since GCC 4.8, 2012)
- Uses the same 3-stage bootstrap introduced in GCC 2.x (1992)
- Supports 8+ programming languages
- Has advanced optimizations (LTO, PGO, auto-vectorization)
- Is the standard compiler on most Linux systems
