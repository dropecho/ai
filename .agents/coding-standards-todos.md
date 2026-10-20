# Coding standards ledger

Findings from the `coding-standards` skill's refactor workflow. IDs are stable — don't
renumber when items are removed. `(unverified)` marks items inferred rather than confirmed
in code. Nothing here is implemented until approved. Terms are from
`.agents/domain-model.md`.

## Summary

| Prefix | Kind |
|---|---|
| `M` | Model change: a change to `.agents/domain-model.md`, made true by the items that implement it |
| `R` | Refactor: same behavior, better shape |
| `T` | Test work |
| `D` | Comment or doc that no longer matches the code |
| `B` | Bug, or behaviour that may not be intended |
| `A` | Public API change; needs a semver decision |

| ID | Kind | What it does | Buys | Needs | Status |
|---|---|---|---|---|---|
| M1 | Model change | Call the GOAP `State` a Goal | Ends the clash with the state machine's State | — | open |
| M2 | Model change | Make World state an explicit value in the Planner instead of a comma-joined string | The planner reads in its own terms | — | done |
| M3 | Model change | Make the child cursor part of Composites, with cursor names instead of iterator ones | `hasNext`/`next` stop pretending to be a Haxe Iterator | — | open |
| R5 | Refactor [simplify] | Each planner graph node holds its World state's condition list, so the string is never split back apart | M2; removes `_parseState` | — | done |
| R20 | Refactor [readability] | Split `generatePlan` into named steps (expand world states, find cheapest goal, collect actions), replacing its four step comments | M2; the 75-line method reads as four lines | R5 | done |
| R6 | Refactor [reuse] | Merge `_satisfiesGoal` and `_preconditionsMet`, which are the same "has all these conditions" check | One check, one name | — | done |
| R7 | Refactor [simplify] | Drop the constructor's sort-and-copy; the cheapest-edge check already keeps the cheapest Action | Removes a `cast` and a duplicate rule | T8 | done |
| A3 | API change | Move `CurrentIterator` into the composite package as a child cursor with `advance()` / `isOnLast()` | M3; a `for` loop over it today silently skips the last child | — | open |
| A1 | API change | Rename GOAP `State` to `Goal` (breaking) | M1 | — | open |
| R10 | Refactor [reuse] | Selector and Sequence are mirror images; share one "run current child, stop on X" step in Composite | One copy of the cursor rules | T6, B10 | approved |
| R11 | Refactor [pattern] | Make CompositeNode and DecoratorNode Haxe `abstract class`es so a missing `execute` is a compile error, not a runtime throw | Compiler enforces what convention does now | — | done |
| R8 | Refactor [sweep] | P15: brace the 7 one-line `if`s, all in the Planner | Preference sweep | — | done |
| R16 | Refactor [sweep] | P18: give the 10 untyped public functions explicit return types (`Null<Motive>` for the most important motive) | Preference sweep; signatures stop changing with bodies | — | done |
| R17 | Refactor [sweep] | P4: doc-comment every public member (most have none) | Preference sweep; the docs target has content | — | done |
| R19 | Refactor [sweep] | P1: name the 7 conditions that don't read as English | Preference sweep | R6, R20 | done |
| R18 | Refactor [sweep] | P20: write the 2 negated logic checks as `== false` in a named value | Preference sweep | — | done |
| T6 | Test [pin] | Pin "one child per tick" for Selector and Sequence | Protects R10 | — | declined: B10 changes this behaviour instead |
| T8 | Test [pin] | Pin that among equal-cost Actions the first given wins | Protects R7 | — | done |
| B10 | Bug (question) | Composites run one child per tick; most behavior trees run on to the next child in the same tick. Intended? | Decides R10's shape | — | approved |
| B11 | Bug | An unknown task name gives a Task node `null`, which fails later with "not a function"; throw at construction, listing registered names | P3; failure where the cause is | — | done |
| B12 | Bug (question) | State machine transitions are keyed by State name, so two States with one name (two instances of one class, as in the tests) share transitions silently | Removes a trap | — | done: keyed by the State object |
| B17 | Bug (question) | An Action's default done check is always true, so a Plan drops every remaining Action after its first update; should the default be "not done", or should a done check be required? | Plans built with defaults run fully | — | open |
| B18 | Bug | `Plan.currentAction` and `Plan.length` are Haxe properties, so in JS they read as `undefined` (only `get_currentAction()` works) and a Plan isn't `for…of`-iterable; A4's accessors only help Haxe callers | JS users can read a Plan | A4 | open |
| B19 | Bug (question) | An any-transition whose target is the current State re-fires every tick (onExit/onEnter again) while its Condition is true; skip transitions to the current State? | No surprise re-entry | — | open |
| B20 | Bug | `toDot()` quirks: current State only marked when no Transition is pending, a self-loop on every State, target-only States not declared, names unquoted (spaces/hyphens break DOT) | A correct State graph | — | open |
| A10 | API change | Blackboard can't list its facts, so tools must know keys in advance (the old FSM demo read a field that no longer exists) | Debug views and demos | — | open |
| B21 | Bug (question) | With equal values, the most important Motive is the later one; should it be the first? | Predictable ties | — | open |
| B22 | Bug (upstream) | `dropecho.ds` Dijkstra keys its distance maps by `Std.string(node)` on JS (AbstractMap is a plain object), which dumps each node's fields; slow, and only distinct because the label is in the dump | Planner speed and safety | — | open |
| B16 | Bug (upstream) | Fix `Queue.enqueueMany` in dropecho.ds (adds to the front on JS), then remove the workaround in `Plan.new` | Removes a workaround | — | open |
| A2 | API change | GOAP and Utility aren't exported in the CJS bundle, while dropecho.ds's Graph/GraphNode/Heap/Queue/Search now are, as top-level names | JS users can reach the planner | — | done |
| A4 | API change | Replace the public `Plan._actions` with `currentAction` and `iterator()`; tests stop reaching into it (finishes R4) | Plan owns its queue | — | partly done: accessors added, tests moved; making `_actions` private waits for the next major |
| D1 | Docs | `architecture.md` is stale (Int blackboard, stub LeafNode, backward-chaining planner) and repeats the concepts; point it at the domain model and keep only the flows | One description of the system | — | done |
| D2 | Docs | AGENTS.md says the Blackboard holds Int facts; it holds Float | Accurate guide | — | done |
| D4 | Docs | README describes another project (`dropecho.hx`, Travis) | A README for this library | — | done |
| A5 | API change · low value | GOAP naming: PascalCase fields and snake_case methods (`preconditions_satisfied`, `delta_time`) unlike the rest; conventions.md asks for the PascalCase fields | Consistency, only in a major | — | open |
| A6 | API change · low value | `Action.new` takes `Float->Void` while the field is `Action_1<Float>` | Matches the interop convention | — | open |
| A7 | API change · low value | Goal `Relevance` is stored but nothing uses it; remove it or use it | No dead field | — | open |
| A8 | API change · low value | Make `LeafNode` abstract too (it is exported and subclassed) | Same as R11 for leaves | R11 | open |
| A9 | API change · low value | `BehaviorTree.new(root = null)` defaults a parameter that it then rejects; make it required | Signature says the rule | — | open |
| B13 | Bug · low value | A condition name containing `,` collides in the World state key | Removes a trap | R5 | open |
| B14 | Bug (question) · low value | `Plan.update` ticks the front Action once even if its done check is already true | — | — | open |
| B15 | Bug (question) · low value | `toDot()` asks every Condition to mark the active edge, so drawing runs game callbacks | — | — | open |
| R12 | Refactor [readability] · low value | Shorten `FSM.addTransition`'s get-or-create | Shorter | — | open |
| R13 | Refactor [readability] · low value | Remove unused imports and `using Lambda` | Less noise | — | done |
| R14 | Refactor [readability] · low value | Build `toDot()` output from lists instead of string concatenation with stray indentation | Readable DOT | — | open |
| T7 | Test [readability] · low value | Remove `trace(util)` and fix swapped `Assert.equals(expected, actual)` arguments | Clear failure messages | — | done |
| T9 | Test [consistency] · low value | Move `test/UtilityTests.hx` to `test/utility/` like the others | P21 | — | done |
| B1–B8, R1–R4, T1–T5 | Earlier rounds | See "Done in earlier rounds" | — | — | done |

## Model changes

### M1 — name: the GOAP `State` is a Goal

As-is: `goap.State` holds the Condition names the agent wants true; the state machine also
has `State` (`IState`, exposed as `fsm.State`). To-be: Goal. Why it is simpler: one word,
one concept. Implemented by: A1. Status: open.

### M2 — name: World state is a value the Planner owns

As-is: a world state is a sorted comma-joined string, split back into a list on every
expansion. To-be: the graph node's value is the condition list; the string is only the
node's label. Why it is simpler: the planner works on the concept, not its encoding.
Implemented by: R5, R20. Status: done.

### M3 — move: the child cursor belongs to Composites

As-is: `dropecho.util.CurrentIterator`, shaped like a Haxe Iterator but with different
meanings (`next()` returns the current item; `hasNext()` excludes the last). To-be: a
cursor in `bt.node.composite` with `current()`, `advance()`, `isOnLast()`, `reset()`.
Implemented by: A3. Status: open.

---

## Conventions

- Failures throw with a message that says how to fix it (P3); `FSM.tick` and
  `BehaviorTree.new` already do.
- Cross-target types on public boundaries: `AbstractMap`, `AbstractArray`, `AbstractFunc`.
- GOAP `Action` fields are PascalCase (`.agents/conventions.md`); the rest is camelCase.
- Test helpers: `test/bt/node/TestNode.hx`; FSM test States in `test/fsm/FSMTests.hx`.
- Build outputs (`dist/`, `artifacts/`) are not checked in; nothing generated is.
- Every target is built by `npm run build` (JS CJS, JS ESM, C#, docs XML); tests run on JS.

## Refactoring

### R5 [simplify] — Planner graph nodes hold their World state

**File:** `src/dropecho/ai/goap/Planner.hx:21-58,105-107` `Graph<String, Action>` stores the
label as the value too, and `_parseState` splits the label back into a list for every node.
Target: `Graph<Array<String>, Action>`, `createNode(conditions, key)`, read `current.value`.
Implements: M2.

### R20 [readability] — split `generatePlan` into named steps

**File:** `src/dropecho/ai/goap/Planner.hx:21-96` One 75-line method with four "what"
comments (`// BFS…`, `// Dijkstra…`, `// Pick…`, `// Reconstruct…`), against AGENTS.md's
comment rule. Target: `_expandWorldStates()`, `_cheapestGoal()`, `_actionsTo()`; the
comments go. Implements: M2. Needs: R5.

### R6 [reuse] — one "has all conditions" check

**File:** `src/dropecho/ai/goap/Planner.hx:109-121` `_satisfiesGoal(c)` is
`_preconditionsMet(c, _goal.Preconditions)`. Target: `_hasAll(conditions, required)`.

### R7 [simplify] — drop the constructor sort

**File:** `src/dropecho/ai/goap/Planner.hx:14-19,51-55` Actions are sorted by Cost so the
first edge added is the cheapest, and then each edge is also replaced if a cheaper Action
comes along. Either alone keeps the cheapest. Keep the edge check (it says the rule where
it applies), drop the copy, sort and `cast`. On JS ties behave the same (stable sort);
C# tie order (unverified). Needs: T8.

### R10 [reuse] — Selector and Sequence share one step

**File:** `src/dropecho/ai/bt/node/composite/SelectorNode.hx:13-33`,
`SequenceNode.hx:11-30` The same cursor rules, mirrored on SUCCESS/FAILURE. Target:
`CompositeNode.runCurrentChild(decidingStatus)`; Selector passes SUCCESS, Sequence
FAILURE. Line delta about −15. Needs: T6, B10.

### R11 [pattern] — abstract base nodes

**File:** `CompositeNode.hx`, `DecoratorNode.hx` `execute()` throws
`NotImplementedException`. Target: `abstract class` with `abstract function execute()`.
Neither is exported to JS. Done: Haxe requires subclasses of an abstract class to drop
`override`, so a game's own Haxe subclass with `override function execute` stops compiling.

### R8 [sweep] — P15 across the Planner

**Hits:** 7, all in `Planner.hx` (lines 60, 80, 87, 90, 111, 118, 126). Nothing else in
`src` or `test`.

### R16 [sweep] — P18 return types on public functions

**Hits:** 10: `TaskBank.register`, `UtilityAgent.getMostImportantMotive` (`Null<Motive>`),
`UtilityAgent.toString`, `BehaviorTree.init`/`execute`, `FSM.tick`/`changeToState`/
`addTransition`/`addAnyTransition`/`toDot`.

### R17 [sweep] — P4 doc comments on public members

**Hits:** most public members in `src`; the few with docs are on `FSM` and `Action.update`.

### R19 [sweep] — P1 name conditions

**Hits:** about 7: `Planner.hx:53,111,118,126`, `RepeatUntilNode.hx:12`, `FSM.hx:119,138`.
Some go away with R6 and R20.

### R18 [sweep] — P20 negated logic checks

**Hits:** 2: `SelectorNode.hx:24` (`!hasNext()`), `FSM.hx:93` (`!_transitions.exists`).

## Tests

### T6 [pin] — one child per tick

**File:** `test/bt/node/composite/` A Sequence of two succeeding children returns RUNNING on
the first tick and has not run the second child; mirror for Selector. Before R10.

### T8 [pin] — equal-cost tie

**File:** `test/goap/PlannerTests.hx` Two Actions with the same Cost and effect: the first
given is planned. Before R7.

## Docs

### D1 — architecture.md

**File:** `.agents/architecture.md` Says Blackboard is `key→Int`, LeafNode is a stub, the
Planner backward-chains and `isCompleted` recurses; all changed. Its class list repeats the
glossary. Point to `.agents/domain-model.md`; keep the source layout and the flows.

### D2 — AGENTS.md Blackboard type

**File:** `AGENTS.md`, Modules table: "Shared context (key→Int facts)". It is Float.

### D4 — README

**File:** `README.md` Titled `dropecho.hx` with a Travis badge for another repo.

## Bugs

### B10 — composites run one child per tick (question)

**File:** `SelectorNode.hx`, `SequenceNode.hx` When a Sequence child succeeds, the Sequence
returns RUNNING and the next child runs next tick. Most behavior tree libraries continue
to the next child in the same tick. Is this intended?

### B11 — unknown task name fails late

**File:** `src/dropecho/ai/TaskBank.hx:17-19`, `src/dropecho/ai/bt/node/TaskNode.hx:11-13`
`TaskBank.get` returns null; `TaskNode` stores it and the first `execute` fails with a
"not a function" error. Throw in `TaskBank.get` naming the task and the registered ones,
with a `TaskBank.register(...)` example (P3).

### B12 — transitions keyed by State name (question)

**File:** `src/dropecho/ai/fsm/FSM.hx:63-76,93-97` Two State objects with the same
`getName()` share one transition list. The tests name States by class, so two
`WanderState`s would collide. Key by the State itself, or throw on a duplicate name?

### B16 — upstream Queue bug

**File:** `dropecho.ds/src/dropecho/ds/Queue.hx` (other repo), JS branch of
`enqueueMany` uses `List.push`. Fix there with a test, release, bump here, and remove the
loop in `Plan.new`.

### B17 — default done check is always true (question)

**File:** `src/dropecho/ai/goap/Action.hx:15-16`, `Plan.hx` `PostMatcher` defaults to
`() -> true`. `Plan.update` runs the front Action, then `isCompleted` drops every Action
whose done check is true, so with defaults only the first Action ever runs. Found while
writing the README example. Default to "not done", or require a done check?

---

### B18–B21, A10 — found while building the demo site

See the Summary rows; each was hit by a page in `docs/` and worked around there
(`docs/goap.js` `remainingActions`, `docs/fsm.js` flee Condition and `current` class).
A2 also still leaks dropecho.ds's `Graph`, `GraphNode`, `Heap`, `Queue` and `Search` onto
`window` in the browser.

---

## API changes (need a decision)

### A1 — rename GOAP `State` to `Goal`

Breaking for Haxe/C# callers (not exported to JS today). Implements M1. Expand (add
`Goal`, keep `State` as a deprecated typedef), migrate tests, contract in the next major.

### A2 — JS exports for GOAP and Utility

`$hx_exports` in `dist/js/cjs/index.cjs` has `bt.*`, `fsm.FSM`, `Blackboard`, `TaskBank`,
plus `Graph`, `GraphNode`, `Heap`, `Queue`, `dropecho.ds.graph.Search` from dropecho.ds.
No `@:expose` on `Action`, `Plan`, `Planner`, `State`, `Motive`, `UtilityAgent`. Add
`goap.*` / `utility.*` exposes (minor); decide whether the dropecho.ds names should leak.

### A3 — child cursor

Move `dropecho.util.CurrentIterator` to `bt.node.composite.ChildCursor` with `current()`,
`advance()`, `isOnLast()`, `reset()`. Public Haxe path (not exported to JS). Implements M3.

### A4 — `Plan._actions`

Public field with a private-style name; tests dequeue from it. Add `currentAction` and
`iterator()`, move tests, then make `_actions` private (contract is breaking).

---

## Low value

### A5 — GOAP naming

`Action` uses PascalCase fields and snake_case methods/params; the rest of the library is
camelCase. `.agents/conventions.md` asks for the PascalCase fields. Only in a major, if ever.

### A6 — `Action.new` update parameter type

`updateFunc:Float->Void` vs field `UpdateFunc:Action_1<Float>`. Changes the C# signature.

### A7 — Goal `Relevance` unused

Nothing reads it. Remove, or use it to choose among Goals.

### A8 — abstract LeafNode

As R11, for the exported `LeafNode`.

### A9 — required BehaviorTree root

`new(root:Node = null)` then throws on null.

### B13 — comma in a condition name

`["a,b"]` and `["a", "b"]` get the same World state key.

### B14 — first Action ticked after it is done (question)

`Plan.update` ticks the front before dropping finished Actions.

### B15 — `toDot()` runs Conditions (question)

Drawing the state graph calls `getTransition()`, which asks every Condition.

### R12 — `addTransition` get-or-create

**File:** `FSM.hx:63-76`.

### R13 — unused imports

`SelectorNode` (`using Lambda`, `Node`), `SequenceNode` (`using Lambda`), `Planner`
(`AbstractMap`).

### R14 — `toDot()` string building

**File:** `FSM.hx:108-159`.

### T7 — test noise

`UtilityTests.test_lowest` traces; it and `PlannerTests:45` pass `(actual, expected)`.

### T9 — UtilityTests location

`test/UtilityTests.hx` → `test/utility/UtilityTests.hx`.

---

## Done in earlier rounds

B1 SucceederNode double return · B2 Action placeholder docs · B3 LeafNode implemented ·
B6 FSMTests undefined states · B7 PlannerTests `Actions` field · B8 `toDot()` null crash
and stray any-node · R1 Motive what-comment · R2 Blackboard stores Float · R3 `FSM.tick`
throws without a State · R4 `Plan.length` (making `_actions` private is now A4) · T1–T5
Blackboard, TaskBank/TaskNode, UtilityAgent, FSM any-transition/toDot, chained GOAP tests.
(B4, B5 were never filed.)

Fixed in this round, found while restoring a green build: Blackboard `increment` from a
missing key gave NaN; `getMostImportantMotive` always returned null; Plans ran in reverse
on JS (B16's workaround); Planner did not build for C#.
