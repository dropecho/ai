# dropecho.ai

Small game AI toolkit for Haxe, JS and C#: behavior trees, a finite state machine, a GOAP
goal planner and utility motives, sharing one `Blackboard` of facts.

## Install

Haxe:

```bash
lix install haxelib:dropecho.ai
# or
haxelib install dropecho.ai
```

JS / TypeScript:

```bash
npm install @dropecho/ai
```

The JS bundle exposes `Blackboard`, `TaskBank`, the behavior tree classes (`bt.*`),
`fsm.FSM`, the GOAP classes (`goap.*`) and the utility classes (`utility.*`). The examples
below are in Haxe.

## Blackboard

Named `Float` facts shared by the behavior tree and the state machine. A fact that was never
set reads as `0`. `keys()` lists the names of the facts that have been set, sorted.

```haxe
import dropecho.ai.Blackboard;

var bb = new Blackboard();
bb.set("hunger", 2);
bb.increment("hunger"); // 3
bb.get("thirst");       // 0
bb.keys();              // ["hunger"]
```

Besides number facts, a Blackboard holds **typed values**: any data your AI shares, such as a
target entity or a path. Declare a key once, `static final TARGET = new BlackboardKey<Entity>("target");`,
then `bb.setValue(TARGET, enemy)` and `bb.getValue(TARGET)` are type-checked in Haxe and C#; in
JS a key is just its name (`bb.setValue("target", enemy)`). Values and facts are separate
(`keys()` lists facts, `valueKeys()` lists values), a missing value reads as null, and
`hasValue` / `removeValue` check and clear one. `const off = bb.onChange("target", key => ...)`
is called after the fact or value of that name actually changes (including `increment` /
`decrement`, but not writes of an equal value); call `off()` to stop listening.

## Behavior tree

Register Tasks by name, build the tree from nodes, give it a Blackboard, then call
`execute(deltaTime)` once per tick, passing the time since the last tick. Each node returns `SUCCESS`, `FAILURE` or `RUNNING`.

```haxe
import dropecho.ai.Blackboard;
import dropecho.ai.TaskBank;
import dropecho.ai.bt.BehaviorTree;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.bt.node.TaskNode;
import dropecho.ai.bt.node.composite.SequenceNode;

TaskBank.register("is_hungry", (bb, dt) -> bb.get("hunger") > 2 ? NODE_STATUS.SUCCESS : NODE_STATUS.FAILURE);
TaskBank.register("eat", (bb, dt) -> {
	bb.decrement("hunger");
	return NODE_STATUS.SUCCESS;
});

var tree = new BehaviorTree(new SequenceNode([new TaskNode("is_hungry"), new TaskNode("eat")]));
tree.init(new Blackboard());

var status = tree.execute(dt); // call every tick with the time since the last one
```

Register a Task before creating a `TaskNode` that names it.

**Composites.** `SelectorNode` and `SequenceNode` run on to the next child in the same tick
until the result is decided or a child returns `RUNNING`; a `RUNNING` child is resumed next
tick. Pass `true` as the second argument (or set the `reactive` field) to start from the first
child every tick instead, so higher-priority children and earlier conditions are re-checked;
a running child that is no longer reached is halted. `ParallelNode(children, ?successThreshold,
?failureThreshold)` ticks all its children every tick: it succeeds once `successThreshold`
children have succeeded (default: all) and fails once `failureThreshold` have failed (default:
1), or as soon as success can no longer be reached; children still running when it decides are
halted.

**Conditions and guards.** A `ConditionNode` turns a function `(blackboard) -> Bool` into a
leaf that succeeds when it is true and fails when it is false. `GuardNode(check, child, ?abort)`
runs `child` only while `check` is true. Its `AbortMode` says when the check is asked again
while something is already running: `SELF` (the default) every tick while the child runs,
halting it when the check turns false; `LOWER_PRIORITY` lets a non-reactive Selector or
Sequence ask it while a later sibling runs, and if the answer changes in the guard's favour,
the composite halts that sibling and restarts from the guard in the same tick; `BOTH` does
both, and `NONE` asks only when the child is not already running.

**Decorators.** `InverterNode` and `SucceederNode` change a child's result.
`RepeaterNode(child, times)` repeats its child until it has succeeded `times` times and fails
as soon as the child fails; with no `times` it repeats forever and always returns `RUNNING`.
`RetryNode(child, attempts)` runs its child again after each failure, up to `attempts` runs.
`RepeatUntilNode` runs its child until it fails.

**Time.** Time-based nodes use the unit the game passes to `execute(deltaTime)`.
`WaitNode(duration)` stays `RUNNING` until that much time has passed, then succeeds.
`TimeoutNode(child, limit)` fails and halts the child if it is still running after `limit`, and
`CooldownNode(child, cooldown)` fails without running the child for `cooldown` after it
finishes. Time only advances on ticks the node receives.

**Halting.** When a parent abandons a `RUNNING` node it calls `halt()`, so the node can stop
work in progress and start afresh next time. For leaves that are classes rather than
functions, extend `LeafNode`, implement `execute(deltaTime)` (it is abstract; no `override`)
and override `halt()` if the leaf has work to stop. `tree.halt()` stops the whole tree.

## State machine

Implement `IState`, add transitions with a condition, set the starting State, then
`tick()`. After the current State ticks, the first transition whose condition is true is
taken; transitions added with `addAnyTransition` are checked first and apply from any State.
Transitions to the current State are skipped, so a State is never re-entered by `tick()`.

```haxe
import dropecho.ai.Blackboard;
import dropecho.ai.fsm.FSM;
import dropecho.ai.fsm.IState;

class Wander implements IState {
	var bb:Blackboard;
	public function new(bb) this.bb = bb;
	public function getName() return "wander";
	public function onEnter() {}
	public function onExit() {}
	public function tick() bb.increment("hunger");
}

class Eat implements IState {
	var bb:Blackboard;
	public function new(bb) this.bb = bb;
	public function getName() return "eat";
	public function onEnter() {}
	public function onExit() {}
	public function tick() bb.decrement("hunger");
}

var bb = new Blackboard();
var wander = new Wander(bb);
var eat = new Eat(bb);

var fsm = new FSM();
fsm.addTransition(wander, eat, () -> bb.get("hunger") > 2);
fsm.addTransition(eat, wander, () -> bb.get("hunger") <= 0);
fsm.changeToState(wander); // required before the first tick

fsm.tick(); // call every tick
```

Transitions belong to the State object, so States may share a name.
`fsm.toDot()` returns the machine as a Graphviz graph, marking the current State (`class="current"`),
the Transition the next tick would take (`class="active"`) and its target (`class="next"`).

## GOAP planner

An `Action` has a name, an update function, a cost, preconditions and postconditions
(condition names). A `Goal` lists the condition names the agent wants true. The `Planner`
asks a world state provider (a `() -> Array<String>` returning the condition names true right
now) where the game is, finds the cheapest sequence of Actions that makes the Goal true from
there, or returns `null`. Without a provider it plans from no conditions.

```haxe
import dropecho.ai.goap.Action;
import dropecho.ai.goap.Goal;
import dropecho.ai.goap.Planner;

var world:Array<String> = []; // the condition names true in the game
var findWeapon = new Action("find_weapon", dt -> world.push("found_weapon"), 1, [], ["found_weapon"]);
var getWeapon = new Action("get_weapon", dt -> world.push("has_weapon"), 1, ["found_weapon"], ["has_weapon"]);

var plan = new Planner(new Goal(["has_weapon"]), [getWeapon, findWeapon], () -> world).generatePlan();
// plan runs find_weapon, then get_weapon

plan.currentAction(); // the Action running now, or null
plan.remainingActions(); // the Actions left, as an Array
var done = plan.update(dt); // call every tick; true when every Action is done
```

Each tick the Plan updates its front Action and drops it once it is done. An Action without
a done check of its own is done when all its postconditions are in the world state; the
Planner hands its provider to the Plan for that. To decide differently, pass a done check
(a `() -> Bool`) as the last `Action` constructor argument. Creating a Plan that holds an
Action with neither a done check nor a world state provider throws.

## Utility

Motives are named values; the lowest value is the most important.

```haxe
import dropecho.ai.utility.Motive;
import dropecho.ai.utility.Motive.UtilityAgent;

var agent = new UtilityAgent();
agent.motives.push(new Motive("hunger", 0.2));
agent.motives.push(new Motive("sleep", 0.7));

agent.getMostImportantMotive().name; // "hunger"
```

## Develop

```bash
npm install     # also downloads the Haxe libraries with lix
npm run build   # JS (CJS + ESM), C# and docs into dist/ and artifacts/
npm test        # runs the utest suites under test/
```

## License

MIT
