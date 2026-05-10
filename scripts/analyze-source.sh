#!/bin/bash
# GCC Source Code Structure Analysis
# This script examines the actual GCC source code to show
# how the compiler is organized

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$SCRIPT_DIR/../milestone-06-modern/src/gcc-14.2.0"

if [ ! -d "$SRC_DIR" ]; then
    echo "Error: GCC source not found at $SRC_DIR"
    echo "Please run milestone-06-modern/build.sh first to download source."
    exit 1
fi

echo "=============================================="
echo "GCC 14.2.0 Source Code Structure Analysis"
echo "=============================================="
echo ""

# Top-level structure
echo "=== Top-Level Directory Structure ==="
ls -la "$SRC_DIR" | grep -E '^d' | awk '{print $NF}' | grep -v '^\.' | sort
echo ""

# GCC core directory
echo "=== GCC Core Directory (gcc/) ==="
ls "$SRC_DIR/gcc/" | head -30
echo "..."
echo ""

# Frontend structure
echo "=== Frontend Architecture ==="
echo ""
echo "Each language has its own subdirectory in gcc/:"
echo ""
echo "  gcc/c/          - C frontend"
echo "  gcc/cp/         - C++ frontend"
echo "  gcc/fortran/    - Fortran frontend"
echo "  gcc/go/         - Go frontend"
echo "  gcc/d/          - D frontend"
echo "  gcc/rust/       - Rust frontend (experimental)"
echo ""

echo "=== C Frontend Files ==="
ls "$SRC_DIR/gcc/c/"*.cc 2>/dev/null | head -10
echo ""

echo "=== C++ Frontend Files ==="
ls "$SRC_DIR/gcc/cp/"*.cc 2>/dev/null | head -10
echo ""

# Middle-end structure
echo "=== Middle-End (Tree-SSA Optimizations) ==="
echo ""
echo "Core optimization files:"
ls "$SRC_DIR/gcc/tree-ssa"*.cc 2>/dev/null | head -10
echo ""

echo "=== RTL Back-End ==="
echo ""
echo "Register Transfer Language files:"
ls "$SRC_DIR/gcc/"rtl*.cc 2>/dev/null | head -10
echo ""

# Machine descriptions
echo "=== Machine Descriptions ==="
echo ""
echo "Target-specific code:"
echo "  gcc/config/x86_64/   - x86-64 target"
echo "  gcc/config/aarch64/  - ARM64 target"
echo "  gcc/config/i386/     - x86-32 target"
echo "  gcc/config/rs6000/   - PowerPC target"
echo ""

# Count source files
echo "=== Source Code Statistics ==="
echo ""
echo "File counts by language:"
echo "  C++ (.cc):   $(find "$SRC_DIR/gcc" -name "*.cc" | wc -l)"
echo "  C (.c):      $(find "$SRC_DIR/gcc" -name "*.c" | wc -l)"
echo "  Headers (.h): $(find "$SRC_DIR/gcc" -name "*.h" | wc -l)"
echo "  Machine (.md): $(find "$SRC_DIR/gcc" -name "*.md" | wc -l)"
echo ""
echo "Total lines of code:"
find "$SRC_DIR/gcc" \( -name "*.cc" -o -name "*.c" -o -name "*.h" \) -exec wc -l {} + 2>/dev/null | tail -1
echo ""

# Key files
echo "=== Key Compiler Files ==="
echo ""
echo "The compilation pipeline:"
echo ""
echo "  1. Lexer/Scanner:"
echo "     gcc/c/c-parser.cc      - C parser"
echo "     gcc/cp/parser.cc       - C++ parser"
echo ""
echo "  2. AST (GENERIC trees):"
echo "     gcc/tree.h             - Tree node definitions"
echo "     gcc/tree.def           - Tree node types"
echo ""
echo "  3. GIMPLE (3-address code):"
echo "     gcc/gimple.h           - GIMPLE definitions"
echo "     gcc/gimplify.cc        - GENERIC → GIMPLE"
echo ""
echo "  4. SSA Optimizations:"
echo "     gcc/tree-ssa-ccp.cc    - Constant propagation"
echo "     gcc/tree-ssa-dce.cc    - Dead code elimination"
echo "     gcc/tree-ssa-dom.cc    - Dominator optimizations"
echo ""
echo "  5. RTL Generation:"
echo "     gcc/expr.cc            - Expression → RTL"
echo "     gcc/stmt.cc            - Statement → RTL"
echo ""
echo "  6. RTL Optimizations:"
echo "     gcc/regalloc.cc        - Register allocation"
echo "     gcc/sched.cc           - Instruction scheduling"
echo ""
echo "  7. Code Generation:"
echo "     gcc/final.cc           - RTL → Assembly"
echo ""
echo "  8. Machine Descriptions:"
echo "     gcc/config/i386/i386.md - x86 patterns"
echo ""
