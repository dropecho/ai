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

## Behavior tree

Register Tasks by name, build the tree from nodes, give it a Blackboard, then call
`execute()` once per tick. Each node returns `SUCCESS`, `FAILURE` or `RUNNING`.

```haxe
import dropecho.ai.Blackboard;
import dropecho.ai.TaskBank;
import dropecho.ai.bt.BehaviorTree;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.bt.node.TaskNode;
import dropecho.ai.bt.node.composite.SequenceNode;

TaskBank.register("is_hungry", bb -> bb.get("hunger") > 2 ? NODE_STATUS.SUCCESS : NODE_STATUS.FAILURE);
TaskBank.register("eat", bb -> {
	bb.decrement("hunger");
	return NODE_STATUS.SUCCESS;
});

var tree = new BehaviorTree(new SequenceNode([new TaskNode("is_hungry"), new TaskNode("eat")]));
tree.init(new Blackboard());

var status = tree.execute(); // call every tick
```

Register a Task before creating a `TaskNode` that names it. Composites (`SelectorNode`,
`SequenceNode`) run on to the next child in the same tick until the result is decided or a
child returns `RUNNING`; a `RUNNING` child is resumed next tick. Decorators (`InverterNode`, `RepeaterNode`,
`RepeatUntilNode`, `SucceederNode`) wrap a single child. For leaves that are classes
rather than functions, extend `LeafNode` and implement `execute()` (it is abstract; no `override`).

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
(condition names). The `Planner` finds the cheapest sequence of Actions that makes the
goal's conditions true, starting from no conditions, or returns `null`.

```haxe
import dropecho.ai.goap.Action;
import dropecho.ai.goap.Planner;
import dropecho.ai.goap.State;

var findWeapon = new Action("find_weapon", dt -> {}, 1, [], ["found_weapon"]);
var getWeapon = new Action("get_weapon", dt -> {}, 1, ["found_weapon"], ["has_weapon"]);

var plan = new Planner(new State(["has_weapon"]), [getWeapon, findWeapon]).generatePlan();
// plan runs find_weapon, then get_weapon

var done = plan.update(dt); // call every tick; true when every Action is done
```

Each tick the Plan updates its front Action and drops it once its done check is true. The
done check is the optional last constructor argument (`postMatcher`, a `() -> Bool`); it
defaults to always true. With the default, the first `update` runs the first Action and then
drops every Action, so pass a real done check to each Action that should take time.

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
