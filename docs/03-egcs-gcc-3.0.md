# EGCS & GCC 3.0: The Community Fork (1997-2001)

## The EGCS Story

### The Problem (1997)

By 1997, GCC development had stalled under RMS's stewardship:
- Release cycles were very slow (years between versions)
- Patches piled up without review
- The community wanted faster iteration
- Important features (better C++, better optimization) weren't landing

### The Fork (1997)

Cygnus Solutions (a company founded by John Gilmore, employing many GCC
developers) led a fork called **EGCS** (Experimental/Enhanced GNU Compiler
System):

- Based on GCC 2.8 source code
- Faster development pace
- Better C++ support
- Better optimization
- More open contribution model

Key EGCS developers: Jim Wilson, Jeff Law, Jason Merrill, Mark Mitchell.

### The Success (1997-1999)

EGCS quickly became the better compiler:
- More architectures supported
- Better C++ compliance
- Faster compile times
- More active community
- Major Linux distributions shipped EGCS instead of GCC

### The Reunification (1999-2001)

In 1999, the Free Software Foundation officially recognized EGCS as the
successor to GCC. EGCS 1.1.2 was renamed to GCC 2.95.

This was the first (and only) time a major GNU project was forked and
then reunified. The lesson: community-driven development works.

## GCC 3.0 (2001)

### What Changed

GCC 3.0 was the first release after the reunification. It was a major rewrite:

1. **New Middle-End Architecture**
   - Introduced the GENERIC/GIMPLE tree framework
   - Separated front-end (language parsing) from back-end (code generation)
   - Much cleaner architecture

2. **New Optimization Framework**
   - SSA (Static Single Assignment) form for optimizations
   - Better data flow analysis
   - Interprocedural optimization (IPA)

3. **Better C++ Support**
   - Much improved C++ standard compliance
   - Better template handling
   - Exception handling improvements

4. **New Frontend Architecture**
   - Front-ends now output GENERIC trees
   - Middle-end converts GENERIC → GIMPLE → RTL
   - Back-end converts RTL → assembly

### The Architecture (GCC 3.x)

```
Source Code (.c, .cpp, .f90)
    │
    ▼
┌─────────────────────────────────────────────┐
│  Front-Ends (per language)                  │
│  - cc1   (C)                                │
│  - cc1plus (C++)                            │
│  - f951  (Fortran)                          │
│  - jc1   (Java)                             │
│                                             │
│  Output: GENERIC trees                      │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│  Middle-End                                 │
│  - GENERIC → GIMPLE lowering               │
│  - Tree SSA optimizations                   │
│  - Loop optimizations                       │
│  - Alias analysis                           │
│  - Inlining                                │
│                                             │
│  Output: GIMPLE → RTL                       │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│  Back-End                                   │
│  - RTL optimizations                        │
│  - Register allocation                      │
│  - Instruction scheduling                   │
│  - Assembly generation                      │
│                                             │
│  Output: Assembly (.s)                      │
└─────────────────────────────────────────────┘
```

### Build Instructions (GCC 3.4)

```bash
# Download
wget https://ftp.gnu.org/gnu/gcc/gcc-3.4.6/gcc-3.4.6.tar.bz2
tar xjf gcc-3.4.6.tar.bz2
cd gcc-3.4.6

# Out-of-tree build (now standard!)
mkdir objdir && cd objdir
../gcc-3.4.6/configure --prefix=/usr/local \
    --enable-languages=c,c++ \
    --disable-multilib

# 3-stage bootstrap
make -j$(nproc) bootstrap

# Or profiled bootstrap (4 stages with PGO)
make -j$(nproc) profiledbootstrap
```

### The profiledbootstrap (New in 3.x/4.x)

```
Stage 1: Build with system compiler
Stage 2: Build with Stage 1, instrumented (-fprofile-generate)
  → Run Stage 2 compiler on test suite to collect profile data
Stage 3: Build with Stage 1 compiler + profile data (-fprofile-use)
  → This produces an OPTIMIZED compiler

Result: A compiler that's 5-15% faster because hot code paths
        are optimized based on real compilation workloads.
```

## Significance

The EGCS fork proved that open-source projects can be forked and reunified
when the original governance doesn't serve the community. GCC 3.0's
architecture (front-end/middle-end/back-end separation) is still the
foundation of modern GCC.
