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
Behavior tree:  Blackboard → BehaviorTree.init → every node     ;  tick: execute() → root → … → task → Status
State machine:  tick() → current State.tick() → first true Condition (any-transitions first) → change State
Goal planner:   Goal + Actions → Planner → Plan  ;  tick: Plan.update(dt) → front Action.update(dt)
Utility:        Motives → UtilityAgent → most important Motive (lowest value)
```

The four modules do not know about each other. Behavior tree and state machine know the
Blackboard; the goal planner and utility do not. The goal planner depends on `dropecho.ds`
(`Graph`, `Search.dijkstra`, `Queue`).

## Actors

| Actor | Is | Reaches the system through | May change |
|---|---|---|---|
| Game code | The game using the library | Constructors, `register`, `addTransition`, `tick` / `execute` / `update` | Everything it builds; the Blackboard; the task registry |
| User behaviour | Task functions, State implementations, Action update functions, Conditions | Called by the library during a tick | The Blackboard and game state. Conditions are expected to only read |
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

### State machine

```
no State --changeToState--> State S --tick: S.tick(), then a Condition is true--> onExit S, onEnter T --> State T
```

Any-transitions are checked before S's own transitions; the first true Condition wins.

### Plan

```
Actions pending --update(dt): front Action.update(dt)--> pending
                --front Action's done check is true (checked on update and isCompleted)--> front dropped
                --no Actions left--> completed
```

## Invariants

| Invariant | Enforced by |
|---|---|
| A missing Blackboard fact reads as 0 | `Blackboard.get` (also used by `increment` / `decrement`) |
| A behavior tree has a root | `BehaviorTree.new` throws |
| A Task node only refers to a registered Task: an unknown name throws when the node is built | `TaskBank.get` |
| Every Composite and Decorator defines `execute` | Compiler: `CompositeNode` and `DecoratorNode` are abstract classes |
| A state machine ticks only once it has a State | `FSM.tick` throws |
| A Transition is taken only from the State object it was added for, even if another State has the same name | `FSM._transitions` (an `ObjectMap` keyed by State) |
| A composite returns to its first child whenever it returns SUCCESS or FAILURE | `CompositeNode.runChildren` |
| A composite returns RUNNING only when its current child returned RUNNING | `CompositeNode.runChildren` |
| The Planner never changes the caller's Action list | `Planner` only reads it |
| Among Actions with the same Cost and effect, the Planner keeps the first given | `Planner.generatePlan` replaces an edge only for a strictly cheaper Action |
| A Plan is the cheapest sequence of Actions (by total Cost) that reaches the Goal from an empty world state | `Planner.generatePlan` (Dijkstra over every reachable world state) |
| A Plan runs its Actions in the order the Planner chose | `Plan.new` enqueues one at a time |

## Glossary

### Shared

- **Blackboard:** the shared facts an agent's AI reads and writes, each a named number. A
  fact never set reads as 0. Owner: `dropecho.ai.Blackboard`; called `context` in nodes.

### Behavior tree

- **Behavior tree:** a tree of nodes run once per tick; the root's status is the tree's
  status. Owner: `bt.BehaviorTree`.
- **Node:** one step of a behavior tree. It is given the Blackboard once, then executed
  each tick and answers with a Status. Owner: `bt.node.Node`, built on `IExecutable<T>`.
- **Status:** a node's answer for this tick: SUCCESS, FAILURE or RUNNING (not finished,
  ask again next tick). Owner: `bt.node.NODE_STATUS`.
- **Task:** a game-defined function that does the work of a leaf: it gets the Blackboard
  and returns a Status. Owner: `dropecho.ai.Task` (typedef in `TaskBank.hx`).
- **Task registry:** where game code registers Tasks by name, so trees can refer to them
  by name. Owner: `dropecho.ai.TaskBank` (`register`, `get`).
- **Task node:** a leaf that runs a registered Task. Owner: `bt.node.TaskNode`.
- **Leaf node:** the base for game-defined leaves that are classes instead of Tasks.
  Owner: `bt.node.LeafNode`.
- **Composite:** a node with several children, run in order; in one tick it runs on to
  the next child until the result is decided or a child is RUNNING. Owner:
  `bt.node.composite.CompositeNode`.
  - **Selector:** succeeds at the first child that succeeds; fails if all fail.
    Owner: `SelectorNode`.
  - **Sequence:** fails at the first child that fails; succeeds if all succeed.
    Owner: `SequenceNode`.
- **Decorator:** a node that wraps one child and changes its Status. Owner:
  `bt.node.decorator.DecoratorNode`.
  - **Inverter:** swaps SUCCESS and FAILURE. Owner: `InverterNode`.
  - **Repeater:** runs its child every tick and is always RUNNING. Owner: `RepeaterNode`.
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
- **State graph:** the state machine drawn as Graphviz DOT, with the current State and the
  Transition about to be taken marked active. Owner: `FSM.toDot`.

### Goal planner

- **Condition name:** a word for something true about the world, such as `has_weapon`.
  Owner: `String` in `Action.Preconditions` / `Postconditions` and `State.Preconditions`.
- **World state:** the set of Condition names true at one point in a plan. Planning starts
  from the empty world state. Owner: the value of each node in `Planner`'s graph
  (`Array<String>`); the node's label is the sorted comma-joined key from `_stateKey`.
- **Action:** something an agent can do, with a Cost, the Condition names it needs
  (preconditions), the Condition names it makes true (postconditions), and an update
  function run each tick while it is the current Action. Owner: `goap.Action`;
  `ActionType` is its name.
- **Done check:** a game-defined question that says whether the current Action has
  finished in the running game. It is separate from the postconditions, which are only
  used to plan. Owner: `Action.PostMatcher`, asked through `postconditions_satisfied()`.
  `PreMatcher` / `preconditions_satisfied()` is the same kind of check before starting;
  nothing in the library calls it.
- **Goal:** the Condition names the agent wants true. Owner: `goap.State` (field
  `Preconditions`; `Relevance` is stored but unused).
- **Planner:** finds the cheapest Plan from the empty world state to a Goal using the given
  Actions, or none. Owner: `goap.Planner.generatePlan`.
- **Plan:** the Actions to run in order. Each tick the front Action updates, and Actions
  whose done check is true are dropped. Owner: `goap.Plan`; `currentAction` is the front
  Action, and iterating a Plan gives the remaining Actions in order.

### Utility

- **Motive:** a named need with a value; the lower the value, the more urgent. Owner:
  `utility.Motive`.
- **Utility agent:** holds Motives and picks the most important one, the lowest. Owner:
  `utility.UtilityAgent` (in `Motive.hx`).

### Internals

- **Child cursor:** a composite's position in its children. Owner:
  `dropecho.util.CurrentIterator`. Its `next()` returns the current child and moves on, and
  `hasNext()` means "is there a child after the current one".
- **NotImplementedException:** thrown by `LeafNode.execute`, which game code must override.
  Owner: `dropecho.util.NotImplementedException`.

## Explain test

Game code builds an agent's AI from one of four tools. A behavior tree is given a
Blackboard and executed each tick; its Composites run their children in order, running on
to the next child in the same tick until one decides or is RUNNING, and Decorators change
a child's Status, down to Task nodes that run Tasks from the
Task registry. A state machine ticks its current State, then takes the first Transition
whose Condition is true, any-transitions first. A Planner searches every World state
reachable from the empty one using Actions' preconditions and postconditions, and returns
the cheapest Plan to the Goal; the Plan then updates its front Action each tick and drops
each Action whose done check is true. A Utility agent picks the Motive with the lowest
value.
