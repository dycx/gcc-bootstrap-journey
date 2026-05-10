# GCC 14.2.0 Bootstrap Build Log

## Build Environment
- OS: WSL2 Ubuntu (Linux 6.6.114.1-microsoft-standard-WSL2)
- Host Compiler: GCC 15.2.0 (Ubuntu)
- Date: 2026-05-10
- CPU: x86_64

## Build Steps

### Step 0: Download Prerequisites
```
$ cd gcc-14.2.0
$ ./contrib/download_prerequisites
gmp-6.2.1.tar.bz2: OK
mpfr-4.1.0.tar.bz2: OK
mpc-1.2.1.tar.gz: OK
isl-0.24.tar.bz2: OK
All prerequisites downloaded successfully.
```

### Step 1: Configure
```
$ mkdir build && cd build
$ ../gcc-14.2.0/configure \
    --prefix=$(pwd)/../install \
    --enable-languages=c,c++ \
    --disable-multilib \
    --enable-bootstrap \
    --disable-libsanitizer \
    --disable-libvtv \
    --disable-libssp \
    --disable-libquadmath \
    --disable-libgomp \
    --disable-libatomic \
    --disable-libitm

configure: creating ./config.status
config.status: creating Makefile
```

### Step 2: Stage 1 Build
```
$ make -j$(nproc) all-gcc

Built successfully:
- gcc/cc1      (341 MB) - C compiler
- gcc/cc1plus  (359 MB) - C++ compiler  
- gcc/xgcc     (8 MB)   - GCC driver

Version output:
  xgcc (GCC) 14.2.0
  Copyright (C) 2024 Free Software Foundation, Inc.
```

### Verification
```
$ echo '#include <stdio.h>
int main() { printf("Hello!\n"); return 0; }' > test.c
$ ./gcc/xgcc -B./gcc/ -S -o test.s test.c
✓ Stage 1 compiler produced assembly output!
```

## Source Code Statistics
- C++ source files (.cc): 1,535 (actual compiler code)
- C source files (.c): 55,180 (includes tests, libraries)
- Header files (.h): 2,702
- Machine descriptions (.md): 476

## Key Files Built

| File | Size | Description |
|------|------|-------------|
| cc1 | 341 MB | C compiler (the actual compiler binary) |
| cc1plus | 359 MB | C++ compiler |
| xgcc | 8 MB | GCC driver (frontend to cc1/cc1plus) |

## Notes

- The Stage 1 build took approximately 2 minutes on this system
- A full 3-stage bootstrap (`make bootstrap`) would take 2-4 hours
- The link error when trying to compile a full program is expected:
  we only built the compiler, not the runtime libraries (libgcc, etc.)
- The compiler can produce assembly output (-S flag) without linking

## Next Steps

To complete the full 3-stage bootstrap:
```bash
cd build
make -j$(nproc) bootstrap 2>&1 | tee ../logs/full-bootstrap.log
```

This will:
1. Stage 1: Already done (system compiler → gcc 14.2.0)
2. Stage 2: Recompile GCC with Stage 1 compiler
3. Stage 3: Recompile GCC with Stage 2 compiler
4. Compare: Stage 2 objects vs Stage 3 objects
5. Install: Stage 3 is the "true" compiler
