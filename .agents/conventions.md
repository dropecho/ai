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

- `CompositeNode.execute()` and `DecoratorNode.execute()` throw `NotImplementedException` — subclasses must override.
- Do not instantiate `CompositeNode` or `DecoratorNode` directly.

## BT Node State

- Composite nodes use `CurrentIterator<Node>` to track position across ticks — reset it in the same call where you return a terminal status (SUCCESS or FAILURE).
- Do not store per-tick state on the `Blackboard` unless it must persist across tree restarts.

## GOAP Conventions

- `Action` fields are PascalCase (`ActionType`, `Cost`, `Preconditions`, `Postconditions`) — follow this for consistency.
- Preconditions and Postconditions are `Array<String>` — use descriptive lowercase strings as condition names (e.g. `"has_weapon"`, `"enemy_dead"`).
- `Planner` sorts actions by `Cost` ascending on construction — don't mutate `_availableActions` after that.

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
