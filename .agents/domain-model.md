# Domain model

What dropecho.ai is made of: its concepts, who may change them, and what always holds. This
file describes the code **as it is on this branch**. Proposed changes are `M` items in
`.agents/coding-standards-todos.md` and in the pull request that makes them; they are
written in here by the commit that makes them true. Use these terms, and only these, in
code, tests, docs and reviews.

## Purpose

A small game AI toolkit for Haxe, JS and C# games: four independent ways to decide what an
agent does next (behavior tree, state machine, goal planner, utility motives), sharing one
blackboard of facts.

## Flow

```
Behavior tree:  Blackboard → BehaviorTree.init → every node     ;  tick: execute(deltaTime) → root → … → task → Status ; abandoned RUNNING nodes ← halt()
State machine:  tick() → current State.tick() → first true Condition among Transitions to another State (any-transitions first) → change State
Goal planner:   World state provider + Goal + Actions → Planner → Plan  ;  tick: Plan.update(dt) → front Action.update(dt)
Utility:        Motives → UtilityAgent → most important Motive (lowest value, first on a tie)
```

The four modules do not know about each other. Behavior tree and state machine know the
Blackboard; the goal planner and utility do not. The goal planner depends on `dropecho.ds`
(`Graph`, `Search.dijkstra`, `Queue`).

## Actors

| Actor | Is | Reaches the system through | May change |
|---|---|---|---|
| Game code | The game using the library | Constructors, `register`, `addTransition`, `generatePlan`, `tick` / `execute` / `update` | Everything it builds; the Blackboard; the task registry |
| User behaviour | Task functions, State implementations, Action update functions and done checks, Conditions, world state providers | Called by the library during a tick | The Blackboard and game state. Conditions are expected to only read |
| The library | Nodes, FSM, Plan | Its own fields | Only its own position: a composite's current child, the FSM's current State, a Plan's remaining Actions |

## Lifecycles

### Composite position

```
child 0 --child RUNNING--> same child (parent returns RUNNING; resumed next tick)
        --child finishes, not the deciding status, more children--> next child, run in the same tick
        --deciding status, or last child finished--> back to child 0 (parent returns that status)
```

The deciding status is SUCCESS for a Selector and FAILURE for a Sequence. Within one tick a
composite **runs on through its children** until one returns the deciding status, the last
child finishes, or a child is RUNNING. A composite returns RUNNING only when a child is
RUNNING; next tick it resumes that child without re-running the children before it.
A reactive composite instead starts from its first child every tick, so it never resumes a
child. A child that was RUNNING and is not reached again (an earlier child decided, or a
different child is now RUNNING) is halted.

### Node run

```
idle --execute--> RUNNING --execute--> RUNNING …
                          --execute returns SUCCESS/FAILURE--> idle
                          --parent abandons it: halt()--> idle (per-run state cleared, running children halted)
```

### State machine

```
no State --changeToState--> State S --tick: S.tick(), then a Condition is true--> onExit S, onEnter T --> State T
```

Any-transitions are checked before S's own transitions; the first true Condition wins.
Transitions whose target is S itself are skipped (their Condition isn't asked), so `tick`
never re-enters the current State; only an explicit `changeToState(S)` re-runs onExit/onEnter.

### Plan

```
new Plan --an Action has no done check and there is no world state provider--> throws
Actions pending --update(dt): drop done Actions, then the first not done .update(dt)--> pending
                --front Action is done (its done check, or else all its postconditions in
                  the provider's current world state; checked on update and isCompleted)--> front dropped
                --no Actions left--> completed
```

## Invariants

| Invariant | Enforced by |
|---|---|
| A missing Blackboard fact reads as 0 | `Blackboard.get` (also used by `increment` / `decrement`) |
| A behavior tree has a root | `BehaviorTree.new` requires `root` and throws on null |
| A Task node only refers to a registered Task: an unknown name throws when the node is built | `TaskBank.get` |
| Every Composite, Decorator and Leaf node defines `execute` | Compiler: `CompositeNode`, `DecoratorNode` and `LeafNode` are abstract classes |
| A state machine ticks only once it has a State | `FSM.tick` throws |
| `tick` never takes a Transition to the current State | `FSM.getTransition` skips them |
| The State graph has one node per State object and one edge per Transition; States sharing a name stay separate | `FSM.toDot` (DOT ids by object identity) |
| On a tie, the first Motive in `motives` is the most important | `UtilityAgent.getMostImportantMotive` |
| A Transition is taken only from the State object it was added for, even if another State has the same name | `FSM._transitions` (an `ObjectMap` keyed by State) |
| A composite returns to its first child whenever it returns SUCCESS or FAILURE | `CompositeNode.runChildren` |
| A composite returns RUNNING only when its current child returned RUNNING | `CompositeNode.runChildren` |
| A reactive composite starts every tick at its first child | `CompositeNode.runChildren` resets the child cursor when `reactive` |
| A RUNNING node that its parent will not tick again is halted | `CompositeNode.runChildren` / `halt`, `DecoratorNode.halt`, `BehaviorTree.halt` |
| Every node in a tick gets the same delta time | `BehaviorTree.execute(deltaTime)` passes it down; composites and decorators forward it |
| A Condition node never returns RUNNING | `ConditionNode.execute` |
| A Guard never runs its child in a tick where it found its Check false | `GuardNode.execute` |
| A lower-priority abort happens only in a non-reactive composite with a running child, from a Guard before it whose Check changed in its favour | `CompositeNode._abortLowerPriorityIfAsked`, `GuardNode.wantsToAbortLowerPriority` |
| A Parallel ticks a child at most once per run after it finishes, and halts every child still RUNNING when it decides | `ParallelNode.execute` |
| Repeat, Retry and Parallel counts and thresholds are valid | constructors throw |
| A counted Repeater or a Retry starts its count afresh when it finishes or is halted | `RepeaterNode`, `RetryNode` |
| Time-based durations are finite and at least 0 | `Duration.check` throws |
| A Timeout never ticks its child after the limit | `TimeoutNode.execute` checks first |
| Halting a Cooldown keeps an active cooldown | `CooldownNode` keeps the inherited `halt` |
| The Planner never changes the caller's Action list | `Planner` only reads it |
| Among Actions with the same Cost and effect, the Planner keeps the first given | `Planner.generatePlan` replaces an edge only for a strictly cheaper Action |
| A Plan is the cheapest sequence of Actions (by total Cost) that reaches the Goal from the world state provider's current world state (the empty one if none is given) | `Planner.generatePlan` (Dijkstra over every reachable world state) |
| Every Action in a Plan has a way to finish: its own done check, or a world state provider on the Plan | `Plan.new` throws |
| Condition names containing `,` stay distinct in a world state | `Planner._stateKey` (JSON-encoded sorted names) |
| Only the Plan changes its remaining Actions | `Plan._actions` is private |
| An Action that is already done is never updated | `Plan.update` drops done Actions before updating |
| A Plan runs its Actions in the order the Planner chose | `Plan.new` enqueues one at a time |

## Glossary

### Shared

- **Blackboard:** the shared facts an agent's AI reads and writes, each a named number. A
  fact never set reads as 0, and it can list the names of the facts that have been set
  (`keys()`, sorted). Owner: `dropecho.ai.Blackboard`; called `context` in nodes.

### Behavior tree

- **Behavior tree:** a tree of nodes run once per tick; the root's status is the tree's
  status. Owner: `bt.BehaviorTree`.
- **Node:** one step of a behavior tree. It is given the Blackboard once, then executed
  each tick with the time since the last tick and answers with a Status. If its parent
  abandons it while RUNNING, it is halted and starts afresh next time. Owner:
  `bt.node.Node` (`execute(deltaTime)`, `halt()`), built on `IExecutable<T>`.
- **Delta time:** the time since the last tick, in the game's own unit; the game passes it to
  `BehaviorTree.execute` and every node receives it. Owner: the `deltaTime` parameter.
- **Halt:** telling a RUNNING node its parent will not tick it again for now, so it stops
  work in progress and clears per-run state. Owner: `Node.halt`.
- **Status:** a node's answer for this tick: SUCCESS, FAILURE or RUNNING (not finished,
  ask again next tick). Owner: `bt.node.NODE_STATUS`.
- **Task:** a game-defined function that does the work of a leaf: it gets the Blackboard
  and the delta time and returns a Status. It has no halt; use a Leaf node for work that
  must be stopped. Owner: `dropecho.ai.Task` (typedef in `TaskBank.hx`).
- **Task registry:** where game code registers Tasks by name, so trees can refer to them
  by name. Owner: `dropecho.ai.TaskBank` (`register`, `get`).
- **Task node:** a leaf that runs a registered Task. Owner: `bt.node.TaskNode`.
- **Leaf node:** the base for game-defined leaves that are classes instead of Tasks.
  Owner: `bt.node.LeafNode`, an abstract class; subclasses implement `execute` and may
  override `halt`.
- **Check:** a game-defined yes/no question about the Blackboard; it should only read.
  Owner: `bt.node.Check` (typedef).
- **Condition node:** a leaf that succeeds when its Check is true and fails when it is
  false; never RUNNING. Owner: `bt.node.ConditionNode`.
- **Wait:** a leaf that is RUNNING until a length of time has passed since its first tick,
  then succeeds and starts afresh. Owner: `bt.node.WaitNode`.
- **Composite:** a node with several children, run in order; in one tick it runs on to
  the next child until the result is decided or a child is RUNNING. Owner:
  `bt.node.composite.CompositeNode`.
  - **Selector:** succeeds at the first child that succeeds; fails if all fail.
    Owner: `SelectorNode`.
  - **Sequence:** fails at the first child that fails; succeeds if all succeed.
    Owner: `SequenceNode`.
  - **Reactive (option):** a Selector or Sequence that starts from its first child every
    tick, so a higher-priority child can take over from a RUNNING one and earlier conditions
    are re-checked. Owner: `CompositeNode.reactive`, set by the constructor's `reactive`
    argument (default false).
- **Parallel:** ticks every unfinished child each tick and decides by counting results:
  SUCCESS once the success threshold have succeeded (default all), FAILURE once the failure
  threshold have failed (default 1) or success is unreachable; children still RUNNING are
  then halted. Owner: `bt.node.composite.ParallelNode`.
- **Decorator:** a node that wraps one child and changes its Status. Owner:
  `bt.node.decorator.DecoratorNode`.
  - **Inverter:** swaps SUCCESS and FAILURE. Owner: `InverterNode`.
  - **Repeater:** with a count, succeeds once the child has succeeded that many times and
    fails as soon as it fails; without one, runs the child every tick and is always
    RUNNING. Owner: `RepeaterNode`.
  - **Retry:** runs the child again after each failure, up to a number of attempts;
    succeeds when the child succeeds, fails when every attempt failed. Owner: `RetryNode`.
  - **Guard (precondition):** runs its child only while its Check is true; otherwise
    FAILURE. Owner: `GuardNode`.
  - **Abort mode:** when a Guard's Check is asked again while something is running. NONE:
    only when its child is not running. SELF (default): every tick while its child runs.
    LOWER_PRIORITY: by its non-reactive parent while a later sibling runs. BOTH: SELF and
    LOWER_PRIORITY. Owner: `bt.node.decorator.AbortMode`.
  - **Lower-priority abort:** a non-reactive composite halts its running child and restarts
    at an earlier Guard whose Check changed in that Guard's favour (to true under a
    Selector, to false under a Sequence). Owner: `CompositeNode` through
    `IAbortsLowerPriority`.
  - **Timeout:** passes the child's Status through, but if the child is still RUNNING after
    a time limit, halts it and fails; each run gets the full limit. Owner: `TimeoutNode`.
  - **Cooldown:** after the child finishes, fails without running it until a length of
    time has passed; time advances only on ticks it receives, and halting keeps it.
    Owner: `CooldownNode`.
  - **Repeat until fail:** RUNNING until the child fails, then SUCCESS. Owner:
    `RepeatUntilNode`.
  - **Succeeder:** SUCCESS whenever the child finishes, whatever it returned. Owner:
    `SucceederNode`.

### State machine

- **State machine:** holds one current State and moves between States when a Condition
  becomes true. Owner: `fsm.FSM`.
- **State:** a game-defined mode an agent is in, with enter, exit and per-tick behaviour.
  Its name is for display; Transitions belong to the State object itself. Owner: `fsm.IState`
  (exposed as `fsm.State`).
- **Transition:** a move to a target State, taken when its Condition is true. Owner:
  `fsm.Transition` (in `FSM.hx`).
- **Condition:** a game-defined yes/no question asked after each tick. Owner:
  `fsm.Condition` (typedef in `FSM.hx`).
- **Any-transition:** a Transition taken from whatever State is current. Owner:
  `FSM.addAnyTransition`.
- **State graph:** the state machine drawn as Graphviz DOT: one node per State, marked
  `current` for the current State, `active` on the Transition the next tick would take and
  `next` on its target. Finding that Transition asks the Conditions. Owner: `FSM.toDot`.

### Goal planner

- **Condition name:** a word for something true about the world, such as `has_weapon`.
  Owner: `String` in `Action.preconditions` / `postconditions` and `Goal.conditions`.
- **World state:** the set of Condition names true at one point in a plan. Planning starts
  from the world state the game provides, or the empty one. Owner: the value of each node
  in `Planner`'s graph (`Array<String>`); the node's label is the JSON-encoded sorted names
  from `_stateKey`.
- **World state provider:** a game-supplied function returning the Condition names true
  right now. The Planner plans from it and hands it to the Plan, which uses it for Actions
  without a done check of their own. Owner: `goap.WorldStateProvider` (typedef of
  `Func_0<Array<String>>`).
- **Action:** something an agent can do, with a Cost, the Condition names it needs
  (preconditions), the Condition names it makes true (postconditions), and an update
  function (`onUpdate`) run each tick while it is the current Action. Owner: `goap.Action`;
  `name` is its name.
- **Done check:** a game-defined question saying whether an Action has finished. Optional:
  an Action without one is done when all its postconditions are in the current world
  state. Owner: `Action.doneCheck` (null means none), asked through
  `Action.isDone(worldState)`. `startCheck` / `canStart()` is the same kind of check before
  starting; nothing in the library calls it.
- **Goal:** the Condition names the agent wants true. Owner: `goap.Goal` (field
  `conditions`).
- **Planner:** finds the cheapest Plan from the current world state to a Goal using the
  given Actions, or none. Owner: `goap.Planner.generatePlan`.
- **Plan:** the Actions to run in order. Each tick the front Action updates, and Actions
  that are done are dropped. Owner: `goap.Plan`; `currentAction()` is the front Action;
  `length()`, `remainingActions()` (an Array) and iteration give the remaining Actions in
  order.

### Utility

- **Motive:** a named need with a value; the lower the value, the more urgent. Owner:
  `utility.Motive`.
- **Utility agent:** holds Motives and picks the most important one, the lowest; on a tie,
  the first in its list. Owner:
  `utility.UtilityAgent` (in `Motive.hx`).

### Internals

- **Child cursor:** a composite's position in its children: which child runs next. Owner:
  `bt.node.composite.ChildCursor`: `current()`, `advance()`, `isOnLast()`, `reset()`.

## Explain test

Game code builds an agent's AI from one of four tools. A behavior tree is given a
Blackboard and executed each tick; its Composites run their children in order, running on
to the next child in the same tick until one decides or is RUNNING (reactive ones start
again from the first child every tick), and Decorators change
a child's Status, down to Task nodes that run Tasks from the
Task registry. A state machine ticks its current State, then takes the first Transition
whose Condition is true, any-transitions first. A Planner searches every World state
reachable from the world state the game provides (or the empty one) using Actions' preconditions and postconditions, and returns
the cheapest Plan to the Goal; the Plan then updates its front Action each tick and drops
each Action that is done. A Utility agent picks the Motive with the lowest
value, the first on a tie.
