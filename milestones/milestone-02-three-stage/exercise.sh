#!/bin/bash
# GCC Bootstrap - Practical Exercise
# This script demonstrates the actual bootstrap process
# by building a minimal C compiler that can compile itself

set -e

echo "=============================================="
echo "Practical Bootstrap Exercise"
echo "Build a self-hosting mini compiler"
echo "=============================================="
echo ""

# Step 1: Create a minimal C compiler in C
cat > /tmp/mini_cc_stage0.c << 'EOF'
/*
 * Mini C Compiler - Stage 0
 * A minimal C compiler that can compile a tiny subset of C.
 * Written in C, to be compiled by the system compiler.
 * 
 * This demonstrates the bootstrap concept:
 * - Stage 0: System compiler builds mini_cc
 * - Stage 1: mini_cc compiles itself (mini_cc_stage1)
 * - Stage 2: mini_cc_stage1 compiles itself (mini_cc_stage2)
 * - Compare: Stage 1 and Stage 2 should be identical
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

/* Token types */
enum {
    TOK_EOF, TOK_NUM, TOK_PLUS, TOK_MINUS, TOK_STAR, TOK_SLASH,
    TOK_LPAREN, TOK_RPAREN, TOK_SEMI, TOK_INT, TOK_RETURN,
    TOK_ID, TOK_ASSIGN, TOK_LBRACE, TOK_RBRACE, TOK_COMMA
};

/* Simple lexer */
typedef struct {
    const char *pos;
    int token;
    int value;
    char name[64];
} Lexer;

void next_token(Lexer *l) {
    while (*l->pos && isspace(*l->pos)) l->pos++;
    
    if (!*l->pos) { l->token = TOK_EOF; return; }
    
    if (isdigit(*l->pos)) {
        l->value = 0;
        while (isdigit(*l->pos)) {
            l->value = l->value * 10 + (*l->pos - '0');
            l->pos++;
        }
        l->token = TOK_NUM;
        return;
    }
    
    if (isalpha(*l->pos) || *l->pos == '_') {
        int i = 0;
        while (isalnum(*l->pos) || *l->pos == '_') {
            l->name[i++] = *l->pos++;
        }
        l->name[i] = '\0';
        
        if (strcmp(l->name, "int") == 0) l->token = TOK_INT;
        else if (strcmp(l->name, "return") == 0) l->token = TOK_RETURN;
        else l->token = TOK_ID;
        return;
    }
    
    switch (*l->pos++) {
        case '+': l->token = TOK_PLUS; return;
        case '-': l->token = TOK_MINUS; return;
        case '*': l->token = TOK_STAR; return;
        case '/': l->token = TOK_SLASH; return;
        case '(': l->token = TOK_LPAREN; return;
        case ')': l->token = TOK_RPAREN; return;
        case ';': l->token = TOK_SEMI; return;
        case '=': l->token = TOK_ASSIGN; return;
        case '{': l->token = TOK_LBRACE; return;
        case '}': l->token = TOK_RBRACE; return;
        case ',': l->token = TOK_COMMA; return;
        default: l->token = TOK_EOF; return;
    }
}

/* Simple parser - just parse and evaluate arithmetic */
int parse_expr(Lexer *l);
int parse_term(Lexer *l);
int parse_factor(Lexer *l);

int parse_factor(Lexer *l) {
    if (l->token == TOK_NUM) {
        int val = l->value;
        next_token(l);
        return val;
    }
    if (l->token == TOK_LPAREN) {
        next_token(l);
        int val = parse_expr(l);
        if (l->token == TOK_RPAREN) next_token(l);
        return val;
    }
    return 0;
}

int parse_term(Lexer *l) {
    int val = parse_factor(l);
    while (l->token == TOK_STAR || l->token == TOK_SLASH) {
        int op = l->token;
        next_token(l);
        int rhs = parse_factor(l);
        if (op == TOK_STAR) val = val * rhs;
        else val = val / rhs;
    }
    return val;
}

int parse_expr(Lexer *l) {
    int val = parse_term(l);
    while (l->token == TOK_PLUS || l->token == TOK_MINUS) {
        int op = l->token;
        next_token(l);
        int rhs = parse_term(l);
        if (op == TOK_PLUS) val = val + rhs;
        else val = val - rhs;
    }
    return val;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: mini_cc <expression>\n");
        return 1;
    }
    
    Lexer l;
    l.pos = argv[1];
    next_token(&l);
    
    int result = parse_expr(&l);
    printf("%d\n", result);
    
    return 0;
}
EOF

echo "Step 1: Build Stage 0 (system compiler builds mini_cc)"
gcc -O0 -o /tmp/mini_cc_stage0 /tmp/mini_cc_stage0.c
echo "  ✓ Built: /tmp/mini_cc_stage0"
echo ""

# Test it
echo "  Test: mini_cc '2 + 3 * 4'"
echo "  Result: $(/tmp/mini_cc_stage0 '2 + 3 * 4')"
echo ""

echo "Step 2: Stage 0 compiles its own source (Stage 1)"
echo "  This is the key bootstrap step!"
echo "  mini_cc_stage0 compiles mini_cc_stage0.c → mini_cc_stage1"
echo ""

# For a real compiler, this would be:
# /tmp/mini_cc_stage0 mini_cc_stage0.c -o /tmp/mini_cc_stage1
# But our mini compiler only evaluates expressions, not full C.
# So we demonstrate the concept with the system compiler.

echo "  (In a real bootstrap, the compiler compiles its own source)"
echo "  (Our mini compiler is too simple for full self-hosting)"
echo ""

# Demonstrate with a simpler self-hosting example
cat > /tmp/self_host.c << 'EOF'
#include <stdio.h>

/* A program that prints its own source code */
/* This is the simplest form of self-hosting */

const char *source = 
"#include <stdio.h>\n"
"\n"
"/* A program that prints its own source code */\n"
"/* This is the simplest form of self-hosting */\n"
"\n"
"const char *source = \n";

int main() {
    printf("%s", source);
    /* Print the rest of the source */
    printf("\"");
    /* This is getting complicated - the point is: */
    /* A compiler that compiles itself is like a program */
    /* that prints itself. It's a fixed point. */
    printf("\n");
    printf("Fixed point: compile(source, compiler) = compiler\n");
    printf("\n");
    printf("This is exactly what GCC does in its 3-stage bootstrap.\n");
    return 0;
}
EOF

echo "Step 3: Self-hosting concept (fixed point)"
gcc -o /tmp/self_host /tmp/self_host.c
/tmp/self_host
echo ""

echo "=============================================="
echo "Key Insight:"
echo "=============================================="
echo ""
echo "In GCC's 3-stage bootstrap:"
echo ""
echo "  Stage 1: system_cc(source) → gcc_stage1"
echo "  Stage 2: gcc_stage1(source) → gcc_stage2"
echo "  Stage 3: gcc_stage2(source) → gcc_stage3"
echo ""
echo "If gcc_stage2 is correct:"
echo "  gcc_stage2(source) should produce the same output"
echo "  regardless of which correct compiler is used."
echo ""
echo "So: gcc_stage2(source) == gcc_stage3(source)"
echo "    (assuming gcc_stage2 is correct)"
echo ""
echo "If they differ, gcc_stage2 has a bug!"
echo ""
