# Project Todos

## Bugs

### B1 — `SucceederNode` has a double `return` keyword
**File:** `src/dropecho/ai/bt/node/decorator/SucceederNode.hx:16`
```haxe
return return NODE_STATUS.RUNNING;  // inner return fires, outer is dead code
```
Fix: remove the duplicate `return`.

### B2 — `Action.hx` has placeholder `/** This is a test */` on every member
**File:** `src/dropecho/ai/goap/Action.hx`
Fields `ActionType`, `Cost`, `Preconditions`, `Postconditions`, `UpdateFunc`, `PreMatcher`, `PostMatcher` and methods `preconditions_satisfied`, `postconditions_satisfied` all carry `/** This is a test */` doc comments that are clearly leftover placeholders. Remove them all.

### B3 — `LeafNode.hx` is an entirely commented-out stub
**File:** `src/dropecho/ai/bt/node/LeafNode.hx`
The class body is 100% commented out. Either implement `LeafNode` as a proper abstract base (interface extending `Node` for user leaf tasks) or delete the file. `TaskNode` already serves the concrete leaf role; `LeafNode` should be the user-facing base to subclass instead of implementing `Node` directly.

---

## Tests

### T1 — `BlackboardTests` has zero test methods
**File:** `test/ai/BlackboardTests.hx`
The class exists with a `bb:Blackboard` field but no tests. Add:
- `test_get_returns_zero_for_missing_key`
- `test_set_and_get_roundtrip`
- `test_increment_increases_value`
- `test_decrement_decreases_value`
- `test_increment_from_zero` (edge case: missing key treated as 0)

### T2 — `TaskBank` and `TaskNode` have no tests
**Files:** *(none yet — create)* `test/ai/TaskBankTests.hx`, `test/bt/node/TaskNodeTests.hx`
`TaskBank` (static registry) and `TaskNode` (leaf that calls registered tasks) are both untested. Add:
- `TaskBankTests`: register a task, retrieve it, verify it runs
- `TaskNodeTests`: init with context, execute calls the registered task, returns correct status

### T3 — `UtilityAgent.getMostImportantMotive()` edge cases not covered
**File:** `test/UtilityTests.hx`
Only one test (two motives, different values). Add:
- Empty motives list → returns `null`
- Single motive → returns that motive
- Equal values → returns one of them (either, non-null)
- Lowest value is first in the list (ordering doesn't affect result)

### T4 — `FSM.addAnyTransition` and `FSM.toDot()` not tested
**File:** `test/fsm/FSMTests.hx`
`addAnyTransition` (global transitions that fire from any state) has no test. `toDot()` has no test at all. Add:
- `test_any_transition_fires_from_any_state` — verify global transition triggers regardless of current state
- `test_toDot_produces_digraph_output` — basic structural check (contains `digraph`, state names, edge arrows)

### T5 — Multi-step GOAP planning not tested
**File:** `test/goap/PlannerTests.hx`
All existing tests use a single-action plan. The planner's backward-chaining logic (where action A's precondition is satisfied by action B's postcondition) has no test. Add:
- `test_when_given_chained_actions_plan_should_contain_both_in_order` — action B postcondition satisfies action A precondition, verify plan contains `[B, A]` in execution order

---

## Refactors

### R1 — Remove "what" comment from `getMostImportantMotive`
**File:** `src/dropecho/ai/utility/Motive.hx:28–30`
```haxe
// loop through array, and get important motive.
// this will typically be the lowest one.
```
These describe *what* the code does, not *why*. Remove per conventions.

### R2 — `Blackboard` stores only `Int`; utility AI motives use `Float`
**File:** `src/dropecho/ai/Blackboard.hx`
`AbstractMap<String, Int>` means callers must scale floats to integers. `Motive.value` is `Float` but can't be stored in the Blackboard. Change to `AbstractMap<String, Float>` and update `get`, `set`, `increment`, `decrement` signatures accordingly. Update any callers (FSMTests uses `increment`/`decrement` with int values — verify they still work with Float arithmetic).

### R3 — `FSM.tick()` panics on null `_currentState`
**File:** `src/dropecho/ai/fsm/FSM.hx`
`_currentState` is null until `changeToState()` is called. `tick()` calls `_currentState?.tick()` safely, but `getTransition()` calls `_currentState?.getName()` which returns null and then `_transitions.exists(null)` — may return false silently. The bigger issue: calling `tick()` before any state is set is a silent no-op with no feedback. Add a guard that throws if `_currentState == null` when `tick()` is called (fail-fast over silent misbehavior).
