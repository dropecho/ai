# AGENTS.md — dropecho.ai

Single source of truth for all AI agents working on this project.
See `.agents/` for deeper reference docs.

---

## Project Overview

**dropecho.ai** (`haxelib: dropecho.ai`, npm: `@dropecho/ai`) is a cross-platform Haxe library
of game AI utilities. It compiles to JS (CJS + ESM) and C#.

- **Version:** 1.0.0
- **License:** MIT
- **Targets:** JS (Node.js, browser), C# (.NET)
- **Test runner:** `haxelib run dropecho.testing` (wraps utest)
- **Source root:** `src/`  · **Tests root:** `test/`

---

## Modules

| Module | Path | Description |
|---|---|---|
| **Behavior Tree** | `src/dropecho/ai/bt/` | Node-based hierarchical AI behavior |
| **FSM** | `src/dropecho/ai/fsm/` | Finite State Machine with typed transitions |
| **GOAP** | `src/dropecho/ai/goap/` | Goal-Oriented Action Planning |
| **Utility AI** | `src/dropecho/ai/utility/` | Motive-driven utility scoring |
| `Blackboard` | `src/dropecho/ai/Blackboard.hx` | Shared context (key→Int facts) |
| `TaskBank` | `src/dropecho/ai/TaskBank.hx` | Static registry of named BT tasks |

See `.agents/architecture.md` for class responsibilities and data flows.

---

## Directory Layout

```
src/dropecho/ai/           # library source
  bt/                      # behavior tree
    node/
      composite/           # SelectorNode, SequenceNode
      decorator/           # InverterNode, RepeaterNode, RepeatUntilNode, SucceederNode
  fsm/                     # FSM, IState, Transition
  goap/                    # Action, Plan, Planner, State
  utility/                 # Motive, UtilityAgent
src/dropecho/util/         # CurrentIterator, NotImplementedException
test/                      # utest test suites (mirroring src structure)
  ai/  bt/  fsm/  goap/  util/
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
