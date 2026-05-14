# dropecho.ai — Project Overview

## What It Is

`dropecho.ai` (npm: `@dropecho/ai`) is a game AI utilities library written in Haxe. It compiles to multiple targets including JavaScript (CJS + ESM) and C#. The library is designed for game developers who need classic AI primitives — behavior trees, finite state machines, goal-oriented action planning, and utility scoring — in a cross-platform package.

## Modules

### Behavior Tree (BT)

Node-based hierarchical behavior execution. Each node returns a `NODE_STATUS` (`SUCCESS`, `FAILURE`, or `RUNNING`) per tick.

- **`BehaviorTree`** — root wrapper around a single child `Node`; holds a `Blackboard` context
- **`Node` / `IExecutable<T>`** — core interfaces (`init(context)` + `execute()`)
- **`NODE_STATUS`** — enum abstract over `Int`: `SUCCESS=0`, `FAILURE=1`, `RUNNING=2`
- **`TaskNode`** — leaf node that looks up and calls a named task from `TaskBank`
- **`TaskBank`** — static registry mapping task names to `Blackboard → NODE_STATUS` functions
- **`Blackboard`** — shared key→Int fact store passed through the tree

Composite nodes (multiple children):
- **`SelectorNode`** — tries children in order; returns SUCCESS on first success, FAILURE if all fail
- **`SequenceNode`** — runs children in order; returns FAILURE on first failure, SUCCESS when all succeed

Decorator nodes (single child wrapper):
- **`InverterNode`** — flips SUCCESS↔FAILURE, passes RUNNING through
- **`RepeaterNode`** — always returns RUNNING (repeats child indefinitely)
- **`RepeatUntilNode`** — returns RUNNING until child returns FAILURE, then returns SUCCESS
- **`SucceederNode`** — always returns SUCCESS (or RUNNING if child is RUNNING)

### Finite State Machine (FSM)

Transition-based state management with typed conditions.

- **`FSM`** — holds current state; `tick()` runs state and checks transitions
- **`IState`** — interface: `getName()`, `onEnter()`, `onExit()`, `tick()`
- **`Transition`** — pairs a target `IState` with a `Func_0<Bool>` condition
- Supports both **state-specific** transitions (`addTransition`) and **global** transitions (`addAnyTransition`)
- `toDot()` exports the graph as Graphviz DOT format

### GOAP (Goal-Oriented Action Planning)

Backward-chaining planner that builds an ordered action sequence to satisfy a goal.

- **`State`** — a goal: list of string preconditions + relevance score
- **`Action`** — has `ActionType`, `Cost`, `Preconditions[]`, `Postconditions[]`, `UpdateFunc`, `PreMatcher`, `PostMatcher`
- **`Planner`** — given a `State` goal and available `Action[]`, generates a `Plan` via backward chaining
- **`Plan`** — ordered `Queue<Action>`; `update(dT)` ticks the current action; dequeues when postconditions satisfied

### Utility AI

Simple motive-based scoring for choosing the highest-priority behavior.

- **`Motive`** — name + float value
- **`UtilityAgent`** — holds a list of motives; `getMostImportantMotive()` returns the motive with the lowest value

### Shared Utilities

- **`CurrentIterator<T>`** — array iterator that tracks current position; supports `reset()` and `current()` without advancing
- **`NotImplementedException`** — extends `haxe.Exception`; thrown by abstract base nodes

## Package Metadata

| Field | Value |
|-------|-------|
| Haxelib name | `dropecho.ai` |
| npm package | `@dropecho/ai` |
| Version | 1.0.0 |
| License | MIT |
| Author | Benjamin Van Treese |
| Classpath | `src/` |
| Haxe version | 4.3.7 |
| JS exports | CJS (`dist/js/cjs/index.cjs`), ESM (`dist/js/esm/index.js`) |

## Build Targets

- JavaScript CJS (Node.js / bundlers)
- JavaScript ESM (modern browsers / bundlers)
- C# (.NET)
- Docs (XML documentation)
