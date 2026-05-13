# Testing

## Framework

- **Test runner:** `dropecho.testing` (run via `haxelib run dropecho.testing` or `npm run test`)
- **Assertions:** `utest` (`utest.Assert`, `utest.Test` base class)
- **Compilation:** `test.hxml` — compiles to `artifacts/js_test.cjs` via hxnodejs

## Structure

Test files mirror source files under `test/`, organized by module:

| Source | Test |
|---|---|
| `src/dropecho/ai/Blackboard.hx` | `test/ai/BlackboardTests.hx` |
| `src/dropecho/ai/bt/BehaviorTree.hx` | `test/bt/BehaviorTreeTests.hx` |
| `src/dropecho/ai/bt/node/composite/SelectorNode.hx` | `test/bt/node/composite/SelectorNodeTests.hx` |
| `src/dropecho/ai/bt/node/composite/SequenceNode.hx` | `test/bt/node/composite/SequenceNodeTests.hx` |
| `src/dropecho/ai/bt/node/decorator/InverterNode.hx` | `test/bt/node/decorator/InverterNodeTests.hx` |
| `src/dropecho/ai/bt/node/decorator/RepeaterNode.hx` | `test/bt/node/decorator/RepeaterNodeTests.hx` |
| `src/dropecho/ai/bt/node/decorator/RepeatUntilNode.hx` | `test/bt/node/decorator/RepeatUntilNodeTests.hx` |
| `src/dropecho/ai/bt/node/decorator/SucceederNode.hx` | `test/bt/node/decorator/SucceederNodeTests.hx` |
| `src/dropecho/ai/fsm/FSM.hx` | `test/fsm/FSMTests.hx` |
| `src/dropecho/ai/goap/Action.hx` | `test/goap/ActionTests.hx` |
| `src/dropecho/ai/goap/Plan.hx` | `test/goap/PlanTests.hx` |
| `src/dropecho/ai/goap/Planner.hx` | `test/goap/PlannerTests.hx` |
| `src/dropecho/util/CurrentIterator.hx` | `test/util/CurrentIteratorTests.hx` |
| `src/dropecho/ai/utility/Motive.hx` | `test/UtilityTests.hx` |

`test/bt/node/TestNode.hx` is a shared helper (not a test class) used by BT node tests.

## Test Helper: `TestNode`

`test/bt/node/TestNode.hx` provides a configurable leaf node for BT tests:
- Set its `status` field to control what `execute()` returns
- Use it to simulate SUCCESS, FAILURE, and RUNNING children in composite/decorator tests

## Writing New Tests

1. Add a `public function test_<description>()` method to the appropriate `*Tests.hx` file.
2. Extend `utest.Test` — do not use Buddy.
3. Use `Assert.equals(expected, actual)`, `Assert.isTrue(cond)`, `Assert.isFalse(cond)`, `Assert.notNull(v)`.
4. For exception tests, wrap in `try/catch (e:Any)` and assert on `e`.
5. Use real `Blackboard` instances — do not mock.
6. Register tasks in `TaskBank` within `setup()` if needed, and keep task names unique to avoid cross-test pollution.
7. Run `npm run test` to verify.

## Known Gaps

- No tests for `TaskNode` or `TaskBank` directly.
- No tests for `UtilityAgent.getMostImportantMotive()` with multiple motives.
- No tests for `FSM.toDot()` output format.
- No tests for `GOAP` with unsatisfiable goals (should return `null` from `generatePlan()`).
- No tests for `Plan.update()` delta time propagation to `Action.UpdateFunc`.
- `LeafNode.hx` is a stub — no tests and no implementation.
