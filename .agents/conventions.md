# Conventions & Patterns

## Language & Formatting

- All source is **Haxe 4.3.7** (see `.haxerc`).
- Use `using Lambda;` and `using StringTools;` for static extensions where applicable.
- Cross-platform types from `dropecho.interop`: `AbstractMap<K,V>`, `AbstractArray<T>`, `AbstractFunc.*`.

## Expose & NativeGen Annotations

- `@:expose("module.ClassName")` on every class exported to JS/C# (e.g. `@:expose("bt.BehaviorTree")`).
- `@:nativeGen` on classes that require native C# class generation (e.g. `FSM`, `Transition`, `IState`).
- `@:nativeChildren` on interfaces whose implementations should be natively generated.

## NODE_STATUS Usage

- Always use the enum abstract values: `NODE_STATUS.SUCCESS`, `NODE_STATUS.FAILURE`, `NODE_STATUS.RUNNING`.
- Never compare against raw integers (`0`, `1`, `2`) — the enum abstract handles conversion transparently.
- The JS target has a companion `NODE_STATUS_IMPL` class (guarded with `#if js`) for runtime exposure.

## Cross-Platform Compatibility

- Use `AbstractMap<K,V>` and `AbstractArray<T>` from `dropecho.interop` in all public APIs — JS callers pass plain objects/arrays, C# callers pass native types.
- Use `AbstractFunc.Func_0<R>`, `AbstractFunc.Action_1<A>`, etc. for callable types in public APIs.
- Avoid JS-specific APIs outside of `#if js ... #end` guards.

## Abstract Base Nodes

- `CompositeNode`, `DecoratorNode` and `LeafNode` are abstract classes: subclasses implement `execute()` without `override`.
- Do not instantiate `CompositeNode` or `DecoratorNode` directly.

## BT Node State

- Composite nodes use a `ChildCursor` to track position across ticks — reset it in the same call where you return SUCCESS or FAILURE.
- Do not store per-tick state on the `Blackboard` unless it must persist across tree restarts.

## Exposed APIs

- Use methods, not Haxe properties, for anything JS must read: properties compile to `get_x()` in the CJS bundle, and genes (ESM) only emits some getters.

## GOAP Conventions

- `Action` members are camelCase like the rest (`name`, `cost`, `preconditions`, `postconditions`, `onUpdate`, `startCheck`, `doneCheck`).
- An Action needs a done check or a world state provider on its Plan; `Plan.new` throws otherwise.
- Preconditions and postconditions are `Array<String>` — use descriptive lowercase strings as condition names (e.g. `"has_weapon"`, `"enemy_dead"`).
- The `Planner` only reads the Action list it is given; among Actions with the same Cost and effect, the first given wins.

## Commit Conventions (Angular style)

Used by semantic-release to determine version bumps:

| Prefix | Bump |
|---|---|
| `feat:` | minor |
| `fix:` | patch |
| `chore:` | none |
| `refactor:` | none |
| `perf:` | none |
| `test:` | none |
| `BREAKING CHANGE:` in footer | major |

## What Not To Do

- Do not add comments explaining *what* code does — names should do that.
- Do not mock `Blackboard` or `TaskBank` in tests — use real instances.
- Do not commit anything under `dist/` or `artifacts/` — they are build outputs.
- Do not use `git add -A`; stage specific files.
- Do not compare `NODE_STATUS` values as raw integers.
- Do not add runtime dependencies; the library must stay dependency-light.
