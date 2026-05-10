#!/bin/bash
# GCC 3-Stage Bootstrap Demonstration
# This script demonstrates the core concept of the 3-stage bootstrap
# using a simplified "compiler" example

set -e

echo "=============================================="
echo "GCC 3-Stage Bootstrap - Core Concept Demo"
echo "=============================================="
echo ""

# Create a simple "compiler" program that compiles a subset of C
cat > /tmp/simple_compiler.c << 'COMPILER_EOF'
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// A trivially simple "compiler" that transforms a very basic language
// This demonstrates the bootstrap concept without real complexity

typedef struct {
    int version;        // Compiler version
    int optimizations;  // Number of optimizations applied
    char name[32];      // Compiler name
} Compiler;

// The "compiler" - transforms source into optimized output
void compile(Compiler *compiler, const char *source, char *output) {
    // Simulate compilation: apply optimizations based on version
    int len = strlen(source);
    int optimized = 0;
    
    for (int i = 0; i < len; i++) {
        output[i] = source[i];
        
        // Simulate optimization: higher version = more optimizations
        if (compiler->version >= 2 && source[i] == ' ') {
            optimized++;
            continue;  // Skip spaces (optimization)
        }
        if (compiler->version >= 3 && source[i] == '\t') {
            optimized++;
            continue;  // Skip tabs (optimization)
        }
    }
    output[len] = '\0';
    compiler->optimizations += optimized;
}

int main() {
    printf("=== 3-Stage Bootstrap Demonstration ===\n\n");
    
    // The "source code" to compile
    const char *source = "hello\tworld  this\tis\t  gcc";
    char output[256];
    
    printf("Source code: \"%s\"\n\n", source);
    
    // Stage 0: System compiler (version 1, basic)
    Compiler stage0 = {1, 0, "system-cc"};
    compile(&stage0, source, output);
    printf("Stage 0 (system compiler \"%s\"):\n", stage0.name);
    printf("  Output: \"%s\"\n", output);
    printf("  Optimizations: %d\n\n", stage0.optimizations);
    
    // Stage 1: GCC built by system compiler (version 2, better)
    Compiler stage1 = {2, 0, "gcc-stage1"};
    compile(&stage1, source, output);
    printf("Stage 1 (GCC built by system compiler \"%s\"):\n", stage1.name);
    printf("  Output: \"%s\"\n", output);
    printf("  Optimizations: %d\n\n", stage1.optimizations);
    
    // Stage 2: GCC built by Stage 1 (version 2, same as stage1)
    Compiler stage2 = {2, 0, "gcc-stage2"};
    compile(&stage2, source, output);
    printf("Stage 2 (GCC built by Stage 1 \"%s\"):\n", stage2.name);
    printf("  Output: \"%s\"\n", output);
    printf("  Optimizations: %d\n\n", stage2.optimizations);
    
    // Stage 3: GCC built by Stage 2 (version 2, same as stage2)
    Compiler stage3 = {2, 0, "gcc-stage3"};
    compile(&stage3, source, output);
    printf("Stage 3 (GCC built by Stage 2 \"%s\"):\n", stage3.name);
    printf("  Output: \"%s\"\n", output);
    printf("  Optimizations: %d\n\n", stage3.optimizations);
    
    // Compare Stage 2 and Stage 3
    char output2[256], output3[256];
    Compiler s2 = {2, 0, "stage2"};
    Compiler s3 = {2, 0, "stage3"};
    compile(&s2, source, output2);
    compile(&s3, source, output3);
    
    printf("=== Bootstrap Verification ===\n");
    printf("Stage 2 output: \"%s\"\n", output2);
    printf("Stage 3 output: \"%s\"\n", output3);
    printf("\n");
    
    if (strcmp(output2, output3) == 0) {
        printf("✓ PASS: Stage 2 == Stage 3\n");
        printf("  The compiler has reached a fixed point.\n");
        printf("  Stage 3 is the \"true\" compiler.\n");
    } else {
        printf("✗ FAIL: Stage 2 != Stage 3\n");
        printf("  The compiler has a bug!\n");
    }
    
    printf("\n");
    printf("=== Why This Works ===\n");
    printf("\n");
    printf("If the compiler is correct:\n");
    printf("  Stage 2 = compile(source, correct_stage1) = correct_output\n");
    printf("  Stage 3 = compile(source, correct_stage2) = correct_output\n");
    printf("  → Stage 2 == Stage 3 ✓\n");
    printf("\n");
    printf("If the compiler has a bug:\n");
    printf("  Stage 2 = compile(source, buggy_stage1) = buggy_output\n");
    printf("  Stage 3 = compile(source, buggy_stage2) = ??\n");
    printf("  → Most bugs produce DIFFERENT output each generation\n");
    printf("  → Stage 2 != Stage 3 → Bug detected! ✗\n");
    printf("\n");
    printf("Only if the bug is \"stable\" (produces itself) would\n");
    printf("Stage 2 == Stage 3 with a buggy compiler. This is rare.\n");
    
    return 0;
}
COMPILER_EOF

echo "Compiling the demo..."
gcc /tmp/simple_compiler.c -o /tmp/simple_compiler
echo "Running the demo..."
echo ""
/tmp/simple_compiler
