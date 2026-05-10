#!/bin/bash
# GCC 14.2.0 Bootstrap Reproduction Script
# This script demonstrates the actual 3-stage bootstrap process
#
# Usage: bash build.sh
# Note: Full bootstrap takes 2-4 hours depending on hardware

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src/gcc-14.2.0"
BUILD_DIR="$SCRIPT_DIR/build"
LOG_DIR="$SCRIPT_DIR/logs"

mkdir -p "$LOG_DIR"

echo "=============================================="
echo "GCC 14.2.0 Bootstrap Reproduction"
echo "=============================================="
echo ""
echo "Source: $SRC_DIR"
echo "Build:  $BUILD_DIR"
echo "Logs:   $LOG_DIR"
echo ""

# Step 0: Download prerequisites
echo "=== Step 0: Download prerequisites (GMP, MPFR, MPC, ISL) ==="
cd "$SRC_DIR"
if [ ! -f gmp-6.3.0.tar.bz2 ]; then
    echo "Downloading prerequisites..."
    ./contrib/download_prerequisites 2>&1 | tee "$LOG_DIR/00-prerequisites.log"
    echo "Done."
else
    echo "Prerequisites already downloaded."
fi
echo ""

# Step 1: Configure
echo "=== Step 1: Configure ==="
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ ! -f Makefile ]; then
    echo "Running configure..."
    "$SRC_DIR/configure" \
        --prefix="$SCRIPT_DIR/install" \
        --enable-languages=c,c++ \
        --disable-multilib \
        --enable-bootstrap \
        --disable-libsanitizer \
        --disable-libvtv \
        --disable-libssp \
        --disable-libquadmath \
        --disable-libgomp \
        --disable-libatomic \
        --disable-libitm \
        --disable-libvtv \
        2>&1 | tee "$LOG_DIR/01-configure.log"
    echo "Configure complete."
else
    echo "Already configured."
fi
echo ""

# Step 2: Show what make bootstrap will do
echo "=== Step 2: Understanding the 3-Stage Bootstrap ==="
echo ""
echo "The 'make bootstrap' command will:"
echo ""
echo "  Stage 1: Compile GCC with system compiler (g++ 15.2.0)"
echo "    - All .cc files compiled with system g++"
echo "    - Object files placed in gcc/stage1/"
echo "    - Produces: xgcc, cc1, cc1plus, lto1"
echo ""
echo "  Stage 2: Compile GCC with Stage 1 compiler"
echo "    - Same .cc files recompiled with Stage 1's xgcc"
echo "    - Uses -O2 -g flags"
echo "    - Object files placed in gcc/stage2/"
echo ""
echo "  Stage 3: Compile GCC with Stage 2 compiler"
echo "    - Same .cc files recompiled with Stage 2's xgcc"
echo "    - Object files placed in gcc/stage3/"
echo ""
echo "  Compare: Stage 2 objects vs Stage 3 objects"
echo "    - If identical → PASS → install Stage 3"
echo "    - If different → FAIL → compiler bug detected"
echo ""

# Step 3: Run the bootstrap (or just stage1 for quick demo)
if [ "$1" = "--full" ]; then
    echo "=== Step 3: Full 3-Stage Bootstrap ==="
    echo "This will take 2-4 hours..."
    make -j$(nproc) bootstrap 2>&1 | tee "$LOG_DIR/03-bootstrap.log"
    echo "Bootstrap complete!"
    
    echo ""
    echo "=== Step 4: Install ==="
    make install 2>&1 | tee "$LOG_DIR/04-install.log"
    echo "Install complete!"
else
    echo "=== Step 3: Stage 1 Only (quick demo) ==="
    echo "Building Stage 1 compiler only (to verify build works)..."
    echo "Run with --full for complete 3-stage bootstrap."
    echo ""
    
    # Just build stage1 to verify the build works
    make -j$(nproc) all-gcc 2>&1 | tee "$LOG_DIR/03-stage1.log"
    
    echo ""
    echo "=== Stage 1 Build Result ==="
    if [ -f gcc/cc1 ]; then
        echo "✓ cc1 built successfully"
    else
        echo "✗ cc1 not found"
    fi
    if [ -f gcc/cc1plus ]; then
        echo "✓ cc1plus built successfully"
    else
        echo "✗ cc1plus not found"
    fi
    if [ -f gcc/xgcc ]; then
        echo "✓ xgcc (driver) built successfully"
    else
        echo "✗ xgcc not found"
    fi
    
    echo ""
    echo "=== Compiler Version ==="
    if [ -f gcc/xgcc ]; then
        ./gcc/xgcc --version | head -3
    fi
fi

echo ""
echo "=============================================="
echo "Bootstrap reproduction complete!"
echo "=============================================="
echo ""
echo "To run the full 3-stage bootstrap:"
echo "  cd $BUILD_DIR"
echo "  make -j\$(nproc) bootstrap"
echo ""
echo "To run profiled bootstrap (PGO-optimized):"
echo "  cd $BUILD_DIR"
echo "  make -j\$(nproc) profiledbootstrap"
