#!/bin/bash
# GCC Historical Bootstrap Demonstration
# This script shows the evolution of GCC bootstrap across versions
#
# We use the current system GCC to demonstrate the concepts,
# since building old GCC versions requires old toolchains.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=============================================="
echo "GCC Bootstrap Evolution - Historical Demo"
echo "=============================================="
echo ""

# ============================================================
# Milestone 1: GCC 1.0 (1987) - The Beginning
# ============================================================
echo "=== Milestone 1: GCC 1.0 (1987) ==="
echo ""
echo "GCC 1.0 was the first GNU C Compiler, written by Richard Stallman."
echo ""
echo "Key characteristics:"
echo "  - Written in K&R C (not ANSI C)"
echo "  - Only C language (no C++)"
echo "  - Manual build process (no configure script)"
echo "  - Manual 2-step bootstrap"
echo ""
echo "Build process (1987):"
echo "  1. Copy config file:  cp config-sun3.h config.h"
echo "  2. Edit Makefile:     CC = /usr/bin/cc"
echo "  3. Build:             make"
echo "  4. Bootstrap:         make clean && make CC=./gcc"
echo ""
echo "There was NO formal 'make bootstrap' target."
echo "No verification (no objcmp, no stage comparison)."
echo ""

# ============================================================
# Milestone 2: GCC 2.0 (1992) - The 3-Stage Bootstrap
# ============================================================
echo "=== Milestone 2: GCC 2.0 (1992) - 3-Stage Bootstrap ==="
echo ""
echo "GCC 2.0 introduced autoconf and the canonical 3-stage bootstrap."
echo ""
echo "The 3-stage process:"
echo "  Stage 1: Compile GCC with system compiler (cc)"
echo "  Stage 2: Compile GCC with Stage 1 compiler"
echo "  Stage 3: Compile GCC with Stage 2 compiler"
echo "  Compare: Stage 2 objects == Stage 3 objects?"
echo ""
echo "Why 3 stages and not 2?"
echo "  A buggy Stage 1 could produce a buggy Stage 2 that"
echo "  happens to compile itself correctly (fixed-point bug)."
echo "  The third stage breaks this cycle."
echo ""

# Demonstrate the concept with a simple example
echo "Demonstrating fixed-point verification concept:"
echo ""
cat > /tmp/gcc_demo.c << 'EOF'
#include <stdio.h>

// Simulate a simple "compiler" that adds 1 to its input
int compile(int source) {
    return source + 1;
}

int main() {
    int stage0_source = 100;  // Original source code
    
    int stage1 = compile(stage0_source);  // Stage 1: system compiler
    int stage2 = compile(stage1);          // Stage 2: Stage 1 output
    int stage3 = compile(stage2);          // Stage 3: Stage 2 output
    
    printf("Stage 0 (source): %d\n", stage0_source);
    printf("Stage 1:          %d\n", stage1);
    printf("Stage 2:          %d\n", stage2);
    printf("Stage 3:          %d\n", stage3);
    printf("\n");
    printf("Compare Stage 2 vs Stage 3: %s\n", 
           stage2 == stage3 ? "PASS (identical)" : "FAIL (different)");
    printf("\n");
    printf("If Stage 2 == Stage 3, the compiler has reached\n");
    printf("a fixed point and is (very likely) correct.\n");
    
    return 0;
}
EOF

gcc /tmp/gcc_demo.c -o /tmp/gcc_demo
/tmp/gcc_demo
echo ""

# ============================================================
# Milestone 3: GCC 4.8 (2012) - C++ Self-Hosting
# ============================================================
echo "=== Milestone 3: GCC 4.8 (2012) - C++ Self-Hosting ==="
echo ""
echo "GCC 4.8 was a watershed moment: the compiler was rewritten in C++."
echo ""
echo "Before GCC 4.8:"
echo "  Any C compiler → GCC (written in C) → GCC (self-hosted)"
echo ""
echo "After GCC 4.8:"
echo "  Any C++ compiler → GCC (written in C++) → GCC (self-hosted)"
echo "                   ↑"
echo "           Now you need a C++ compiler!"
echo ""
echo "This changed the bootstrap dependency chain:"
echo "  - You can't bootstrap GCC 4.8+ with just a C compiler"
echo "  - You need an existing C++ compiler (g++, clang++, etc.)"
echo "  - The 3-stage process works the same, but compiles C++ code"
echo ""

# Show that current GCC is written in C++
echo "Current system GCC is written in C++:"
echo "  $(gcc --version | head -1)"
echo ""
echo "Proof: GCC source files are .cc (C++), not .c (C):"
echo "  gcc/c/c-parser.cc    (C frontend parser)"
echo "  gcc/cp/class.cc      (C++ frontend)"
echo "  gcc/tree-ssa-ccp.cc  (SSA optimization)"
echo ""

# ============================================================
# Milestone 4: Modern GCC - The Full Process
# ============================================================
echo "=== Milestone 4: Modern GCC (14.x) - Full Bootstrap ==="
echo ""
echo "Modern GCC bootstrap prerequisites:"
echo "  - C++ compiler (g++ or clang++)"
echo "  - GMP, MPFR, MPC, ISL libraries"
echo "  - flex, bison, texinfo"
echo ""
echo "The process:"
echo "  1. ./contrib/download_prerequisites"
echo "  2. mkdir build && cd build"
echo "  3. ../configure --enable-languages=c,c++ --enable-bootstrap"
echo "  4. make -j\$(nproc) bootstrap"
echo ""
echo "This runs the same 3-stage process introduced in 1992,"
echo "but now compiling C++ source code instead of C."
echo ""

echo "=============================================="
echo "Historical demo complete!"
echo "=============================================="
