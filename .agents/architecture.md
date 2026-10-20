# Architecture — dropecho.ai

What each concept is and owns is in the glossary of `.agents/domain-model.md`; this file
only maps it onto files and call flows.

## Source Layout

```
src/dropecho/ai/
├── Blackboard.hx              # Blackboard: named Float facts, missing reads as 0
├── TaskBank.hx                # Task registry (name → Task) and the Task typedef
├── bt/
│   ├── BehaviorTree.hx        # Behavior tree root; gives the Blackboard to every node
│   └── node/
│       ├── Node.hx            # Node interface + IExecutable<T>
│       ├── NODE_STATUS.hx     # Status enum abstract: SUCCESS, FAILURE, RUNNING
│       ├── LeafNode.hx        # Base class for game-defined leaves (execute must be overridden)
│       ├── TaskNode.hx        # Leaf that runs a registered Task
│       ├── composite/
│       │   ├── CompositeNode.hx   # Base: children + child cursor
│       │   ├── SelectorNode.hx
│       │   └── SequenceNode.hx
│       └── decorator/
│           ├── DecoratorNode.hx   # Base: wraps one child
│           ├── InverterNode.hx
│           ├── RepeaterNode.hx
│           ├── RepeatUntilNode.hx
│           └── SucceederNode.hx
├── fsm/
│   ├── FSM.hx                 # State machine, plus Transition and the Condition typedef
│   └── IState.hx              # State interface: getName, onEnter, onExit, tick
├── goap/
│   ├── Action.hx              # Action: Cost, pre/postconditions, update function, done check
│   ├── Plan.hx                # Queue<Action>; updates the front Action, drops finished ones
│   ├── Planner.hx             # Builds the cheapest Plan to a Goal
│   └── State.hx               # Goal: the Condition names wanted true
└── utility/
    └── Motive.hx              # Motive and UtilityAgent

src/dropecho/util/
├── CurrentIterator.hx         # Child cursor used by CompositeNode
└── NotImplementedException.hx # Thrown by base nodes' execute()
```

## Behavior Tree Execution Flow

```
game: tree.init(blackboard)              # null → a new Blackboard
  → BehaviorTree.init(context)
    → root.init(context)                 # composites/decorators pass it to every child
      → leaf stores context

game: tree.execute()                     # once per tick
  → root.execute()
    → composite: runChildren(deciding)   # from the current child on, same tick, until decided or RUNNING (domain-model.md, "Composite position")
    → decorator: child.execute(), then changes the Status
      → TaskNode.execute() → its registered Task(context) → Status
```

Tasks are looked up in the `TaskBank` by name, so register them before building the
`TaskNode`s that use them.

## FSM Execution Flow

```
game: fsm.changeToState(initial)         # required before the first tick
game: fsm.tick()
  → current State.tick()
  → first Transition whose Condition is true: any-transitions first, then the current State's
  → if one is found: current.onExit(), target.onEnter(), current = target
```

## GOAP Execution Flow

```
var plan = new Planner(goal, actions).generatePlan();   // null if the Goal is unreachable
  → breadth-first search over every world state reachable from the empty one,
    applying each Action whose preconditions hold; the results form a dropecho.ds Graph
    (nodes = world states, edges = the cheapest Action between two states;
     among equal Costs the first Action given wins)
  → Dijkstra from the empty world state; the reachable state that satisfies the Goal
    with the lowest total Cost wins
  → the Actions along that path, in order, become the Plan

// per game tick:
var done = plan.update(dt);
  → front Action.update(dt)
  → isCompleted(): loop, dropping front Actions whose done check is true;
    true when no Actions are left
```

## Key Design Patterns

1. **`NODE_STATUS` over booleans** — every node returns a three-value Status; RUNNING enables multi-tick behaviours.
2. **`CurrentIterator` for resumable composite traversal** — a composite keeps its position across ticks.
3. **`TaskBank` as indirection** — tree structure is decoupled from behaviour; Tasks are registered globally by name.
4. **`AbstractMap` / `AbstractArray` / `AbstractFunc` in public APIs** — JS callers pass plain objects, C# callers native types.
5. **`NotImplementedException` on base nodes** — `CompositeNode`, `DecoratorNode` and `LeafNode` `execute()` throw; subclasses override.
