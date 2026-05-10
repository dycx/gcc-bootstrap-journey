# GCC Bootstrap Journey

Reproducing and documenting the bootstrapping history of the GNU Compiler Collection (GCC) — from 1987 to present.

## What is Compiler Bootstrapping?

Bootstrapping solves the chicken-and-egg problem: how do you compile a compiler written in language X when you don't have a compiler for X yet?

The answer: **build a minimal version first using some other compiler, then use it to compile itself.**

GCC's 3-stage bootstrap (introduced in GCC 2.x, still used today):

```
Stage 1: Compile GCC sources with system compiler (cc/old gcc)
Stage 2: Compile GCC sources with Stage 1 compiler
Stage 3: Compile GCC sources with Stage 2 compiler

Compare: Stage 2 objects == Stage 3 objects?
  YES → Compiler has reached fixed point → Install Stage 3
  NO  → Compiler has a bug → FAIL
```

Why 3 stages? A buggy Stage 1 could produce a buggy Stage 2 that happens to compile itself correctly (fixed-point bug). The third stage breaks this cycle.

## Timeline

| Year | Version | Key Milestone | Language |
|------|---------|---------------|----------|
| 1987 | GCC 1.0 | First GNU C Compiler, written by RMS | C |
| 1992 | GCC 2.0 | autoconf, 3-stage bootstrap, C++ frontend | C |
| 1997 | EGCS 1.0 | Community fork for faster development | C |
| 2001 | GCC 3.0 | EGCS merged back, major rewrite | C |
| 2005 | GCC 4.0 | Tree-SSA optimization framework | C |
| 2012 | GCC 4.8 | Compiler rewritten in C++! | **C++** |
| 2015 | GCC 5.0 | Major version numbering change | C++ |
| 2020 | GCC 10 | Modern GCC, OpenMP 5.0, C++20 | C++ |
| 2024 | GCC 14 | Latest stable release | C++ |

## Project Structure

```
gcc-bootstrap-journey/
├── README.md                    # This file
├── docs/
│   ├── 01-gcc-1.0-original.md  # GCC 1.0: The beginning
│   ├── 02-gcc-2.0-three-stage.md  # The canonical bootstrap
│   ├── 03-egcs-gcc-3.0.md      # Community fork & merge
│   ├── 04-gcc-4.0-tree-ssa.md  # Optimization revolution
│   ├── 05-gcc-4.8-cpp-hosting.md  # The C++ switchover
│   ├── 06-gcc-modern.md        # Modern GCC bootstrap
│   └── timeline.md             # Visual timeline
├── milestones/
│   ├── milestone-01-original/   # Reproduction attempts
│   ├── milestone-02-three-stage/
│   ├── milestone-03-egcs/
│   ├── milestone-04-tree-ssa/
│   ├── milestone-05-cpp-hosting/
│   └── milestone-06-modern/
└── scripts/
    └── build-all.sh            # Master build script
```

## How to Use

Each `docs/` file contains the historical context and technical details.
Each `milestones/` directory contains reproduction scripts and build logs.

```bash
# View the timeline
cat docs/timeline.md

# Try reproducing a specific milestone
cd milestones/milestone-06-modern
bash build.sh
```

## References

- [GCC Official History](https://gcc.gnu.org/wiki/History)
- [GCC Install Documentation](https://gcc.gnu.org/install/)
- [GCC Internals Manual](https://gcc.gnu.org/onlinedocs/gccint/)
- [Richard Stallman, "Using and Porting GNU CC"](https://gcc.gnu.org/onlinedocs/gcc-2.95.3/gcc.html)
