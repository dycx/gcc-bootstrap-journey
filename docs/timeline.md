# GCC Bootstrap Timeline

```
1984  1987    1992    1997    1999    2001    2005    2012    2015    2020    2024
  │     │       │       │       │       │       │       │       │       │       │
  ▼     ▼       ▼       ▼       ▼       ▼       ▼       ▼       ▼       ▼       ▼
RMS   GCC     GCC     EGCS    EGCS    GCC     GCC     GCC     GCC     GCC     GCC
starts 1.0    2.0     fork    reuni-  3.0     4.0     4.8     5.0     10      14
coding         │       │      fied      │       │       │       │       │       │
  │     │      │       │       │       │       │       │       │       │       │
  │     │      │       │       │       │       │       │       │       │       │
  │   ┌─┴──────────────┴───────┴───────┴─┐     │       │       │       │       │
  │   │  Written in C                     │     │       │       │       │       │
  │   │  Bootstrap: manual 2-step         │     │       │       │       │       │
  │   │  Build: Makefile only              │     │       │       │       │       │
  │   └───────────────────────────────────┘     │       │       │       │       │
  │                                             │       │       │       │       │
  │   ┌─────────────────────────────────────────┴───────┐       │       │       │
  │   │  Written in C                                   │       │       │       │
  │   │  Bootstrap: formal 3-stage (stage2 == stage3)   │       │       │       │
  │   │  Build: autoconf + Makefile                     │       │       │       │
  │   │  Added: C++ frontend, ObjC frontend             │       │       │       │
  │   │  Tree-SSA optimization framework                │       │       │       │
  │   └─────────────────────────────────────────────────┘       │       │       │
  │                                                             │       │       │
  │   ┌─────────────────────────────────────────────────────────┴───────┐       │
  │   │  THE BIG SWITCH: Written in C++ (GCC 4.8)                      │       │
  │   │  Bootstrap: 3-stage (now requires C++ compiler for stage 1)    │       │
  │   │  Build: autoconf + contrib/download_prerequisites              │       │
  │   │  Added: LTO, PGO (profiledbootstrap), auto-vectorization      │       │
  │   └───────────────────────────────────────────────────────────────┘       │
  │                                                                           │
  │   ┌───────────────────────────────────────────────────────────────────────┴─┐
  │   │  Modern GCC (5.x → 14.x)                                              │
  │   │  Written in C++ (since 4.8)                                            │
  │   │  Bootstrap: same 3-stage process                                       │
  │   │  Languages: C, C++, Fortran, Go, D, Ada, Rust                          │
  │   │  Features: LTO, PGO, sanitizers, C++23, OpenMP 5.x                     │
  │   └────────────────────────────────────────────────────────────────────────┘
  │
  │
  ▼
Bootstrapping evolution:

  1987:  Manual 2-step (make CC=cc → make CC=./gcc)
  1992:  Formal 3-stage (stage1 → stage2 → stage3 → compare)
  2005:  + Profiled bootstrap (PGO-optimized compiler)
  2012:  Language switch (C → C++), need C++ compiler to start
  2020+: Same process, more complex (more languages, more optimizations)
```

## Key Transitions

| Transition | Year | What Changed | Bootstrap Impact |
|-----------|------|--------------|------------------|
| GCC 1.0 → 2.0 | 1992 | autoconf, 3-stage bootstrap | Formal verification added |
| GCC 2.x → 3.0 | 2001 | EGCS reunification, new middle-end | Architecture matured |
| GCC 3.x → 4.0 | 2005 | Tree-SSA optimizations | Optimizer on trees, not just RTL |
| GCC 4.7 → 4.8 | 2012 | **C → C++ language switch** | Need C++ compiler to bootstrap |
| GCC 4.x → 5.0 | 2015 | Version numbering change | Cosmetic, same process |
| GCC 5.x → 14.x | 2015-2024 | Incremental improvements | Same 3-stage process |

## The Bootstrap Chain

```
                    ┌─────────────────────────────────────┐
                    │  Stage 0: System C++ Compiler       │
                    │  (g++, clang++, or older GCC)       │
                    └──────────────┬──────────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────────┐
                    │  Stage 1: GCC compiled by Stage 0   │
                    │  - All GCC source → object files    │
                    │  - Linked into xgcc, cc1, cc1plus   │
                    │  - libgcc.a built                    │
                    └──────────────┬──────────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────────┐
                    │  Stage 2: GCC compiled by Stage 1   │
                    │  - Same source, compiled by Stage 1 │
                    │  - Uses -O2 -g flags                 │
                    │  - This is "GCC-built-GCC"           │
                    └──────────────┬──────────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────────┐
                    │  Stage 3: GCC compiled by Stage 2   │
                    │  - Same source, compiled by Stage 2 │
                    │  - Should be IDENTICAL to Stage 2   │
                    └──────────────┬──────────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────────────┐
                    │  Compare: Stage 2 vs Stage 3        │
                    │  - objcmp (binary comparison)       │
                    │  - If identical → PASS → install    │
                    │  - If different → FAIL → bug found  │
                    └─────────────────────────────────────┘
```

## Why 3 Stages?

**2 stages are not enough:**
```
Stage 1: system_cc → gcc_s1
Stage 2: gcc_s1 → gcc_s2

Problem: If gcc_s1 has a bug that makes gcc_s2 also buggy
         but in a way that still compiles itself, you can't
         detect it. This is the "fixed-point bug."
```

**3 stages break the cycle:**
```
Stage 1: system_cc → gcc_s1
Stage 2: gcc_s1 → gcc_s2
Stage 3: gcc_s2 → gcc_s3

If gcc_s1 is buggy:
  - gcc_s2 = compile(source, buggy_gcc_s1) = buggy
  - gcc_s3 = compile(source, buggy_gcc_s2) = ???
  
Most bugs are NOT stable — they produce different bugs each
generation. So gcc_s2 ≠ gcc_s3 → bug detected!

Only if the bug is perfectly stable (buggy_s2 produces itself)
would gcc_s2 == gcc_s3, and the bug would be undetectable.
But such bugs are extremely rare.
```
