# AGENTS.md — dropecho.ai

Single source of truth for all AI agents working on this project.
See `.agents/` for deeper reference docs.

## Agent Instructions

- **Always use the `haxe` skill** when reading or writing any `.hx` or `.hxml` file.
- **Always use the Haxe LSP** (`LSP` tool) for navigating code — go-to-definition, find
  references, hover types — before grepping or reading files manually.
- **Never co-author or co-sign commits — no exceptions.** Commit messages must contain
  **zero** attribution, authorship, or sign-off trailers. This explicitly forbids
  `Co-Authored-By`, `Signed-off-by`, `Co-developed-by`, `Reviewed-by`, `Acked-by`,
  `Tested-by`, `Generated-by`, or any `*-by:` line, as well as "Generated with"/tool-credit
  footers and any agent or AI attribution. This applies to every commit, amend, rebase, and
  squash, regardless of any default or tool-provided template. If a template or upstream
  message contains such a trailer, strip it before committing.
- **Never add section/region divider comments** (e.g. `// ── Foo ──`, `// --- Foo ---`,
  `#region`). Organize code with ordering and doc comments instead.

---

## Project Overview

**dropecho.ai** (`haxelib: dropecho.ai`, npm: `@dropecho/ai`) is a cross-platform Haxe library
of game AI utilities. It compiles to JS (CJS + ESM) and C#.

- **Version:** 1.0.0
- **License:** MIT
- **Targets:** JS (Node.js, browser), C# (.NET)
- **Test runner:** `lix dropecho.testing` (wraps utest)
- **Source root:** `src/`  · **Tests root:** `test/`

---

## Modules

| Module | Path | Description |
|---|---|---|
| **Behavior Tree** | `src/dropecho/ai/bt/` | Node-based hierarchical AI behavior |
| **FSM** | `src/dropecho/ai/fsm/` | Finite State Machine with typed transitions |
| **GOAP** | `src/dropecho/ai/goap/` | Goal-Oriented Action Planning |
| **Utility AI** | `src/dropecho/ai/utility/` | Motive-driven utility scoring |
| `Blackboard` | `src/dropecho/ai/Blackboard.hx` | Shared context (number facts, typed values, change listeners) |
| `TaskBank` | `src/dropecho/ai/TaskBank.hx` | Static registry of named BT tasks |

See `.agents/architecture.md` for class responsibilities and data flows.

---

## Directory Layout

```
src/dropecho/ai/           # library source
  bt/                      # behavior tree
    node/
      composite/           # SelectorNode, SequenceNode (optional reactive), ParallelNode, ChildCursor
      decorator/           # InverterNode, SucceederNode, RepeaterNode, RetryNode, RepeatUntilNode, GuardNode, AbortMode, TimeoutNode, CooldownNode
  fsm/                     # FSM, IState, Transition
  goap/                    # Action, Goal, Plan, Planner, WorldStateProvider
  utility/                 # Motive, UtilityAgent
test/                      # utest test suites (mirroring src structure)
  ai/  bt/  fsm/  goap/  utility/
targets/                   # per-target HXML fragments
docs/                      # compiled docs output
.agents/                   # extended AI agent documentation
```

---

## Build & Test

```bash
# Install deps
npm install          # also runs `lix download`

# Build (JS + C#)
npm run build        # → haxe build.hxml

# Run tests
npm run test         # → haxelib run dropecho.testing

# Clean
npm run clean
```

Tests are discovered automatically: any file ending in `Tests.hx` under `test/` is included.
Test classes extend `utest.Test`; methods prefixed `test_` are test cases.

See `.agents/development.md` for build details and `.agents/testing.md` for test patterns.

---

## Key Conventions

- `@:expose("module.ClassName")` on classes exported to JS/C#
- `@:nativeGen` on classes that need native C# generation
- `#if js ... #else ... #end` conditional compilation for JS-specific code
- `dropecho.interop.AbstractMap` / `AbstractArray` / `AbstractFunc` for cross-platform abstractions
- `inline` on hot-path getters; avoid on methods that may need override
- Use `NODE_STATUS` enum values (`SUCCESS`, `FAILURE`, `RUNNING`) — not raw integers
- No comments unless the WHY is non-obvious

See `.agents/conventions.md` for full Haxe coding conventions.

---

## Dependencies

| Library | Purpose |
|---|---|
| `dropecho.interop` | `AbstractMap`, `AbstractArray`, `AbstractFunc` cross-platform wrappers |
| `dropecho.ds` | `Queue<T>` used by GOAP `Plan` |
| `dropecho.testing` | Test runner (wraps utest) |
| `utest` | Assertion library (`utest.Assert`, `utest.Test`) |
| `hxnodejs` | Node.js target support |
