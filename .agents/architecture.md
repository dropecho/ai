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
│       ├── LeafNode.hx        # Abstract base for game-defined leaves (implement execute, may override halt)
│       ├── TaskNode.hx        # Leaf that runs a registered Task
│       ├── ConditionNode.hx   # Leaf: SUCCESS when its Check is true, else FAILURE
│       ├── Check.hx           # Check typedef: Blackboard -> Bool
│       ├── WaitNode.hx        # Leaf: RUNNING until a duration has passed
│       ├── Duration.hx        # Validates durations for time-based nodes
│       ├── composite/
│       │   ├── CompositeNode.hx   # Base: children, child cursor, running child, lower-priority aborts
│       │   ├── ChildCursor.hx     # Which child runs next
│       │   ├── IAbortsLowerPriority.hx
│       │   ├── SelectorNode.hx    # Optional reactive flag
│       │   ├── SequenceNode.hx    # Optional reactive flag
│       │   └── ParallelNode.hx    # Ticks all children; success/failure thresholds
│       └── decorator/
│           ├── DecoratorNode.hx   # Base: wraps one child, forwards halt
│           ├── InverterNode.hx
│           ├── SucceederNode.hx
│           ├── RepeaterNode.hx    # Optional success count
│           ├── RetryNode.hx
│           ├── RepeatUntilNode.hx
│           ├── GuardNode.hx       # Runs its child while a Check holds
│           ├── AbortMode.hx       # NONE, SELF, LOWER_PRIORITY, BOTH
│           ├── TimeoutNode.hx
│           └── CooldownNode.hx
├── fsm/
│   ├── FSM.hx                 # State machine, plus Transition and the Condition typedef
│   └── IState.hx              # State interface: getName, onEnter, onExit, tick
├── goap/
│   ├── Action.hx              # Action: cost, pre/postconditions, onUpdate, optional done check
│   ├── Goal.hx                # Goal: the Condition names wanted true
│   ├── Plan.hx                # Private queue of Actions; updates the front one, drops those that are done
│   ├── Planner.hx             # Builds the cheapest Plan to a Goal from the current world state
│   └── WorldStateProvider.hx  # Typedef: game function returning the Condition names true now
└── utility/
    └── Motive.hx              # Motive and UtilityAgent

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
var plan = new Planner(goal, actions, worldState).generatePlan();   // null if the Goal is unreachable
  → breadth-first search over every world state reachable from worldState() (or the empty one),
    applying each Action whose preconditions hold; the results form a dropecho.ds Graph
    (nodes = world states, edges = the cheapest Action between two states;
     among equal Costs the first Action given wins)
  → Dijkstra from that start world state; the reachable state that satisfies the Goal
    with the lowest total Cost wins
  → the Actions along that path, in order, become the Plan, which gets the same provider
    (new Plan throws if an Action has no done check and there is no provider)

// per game tick:
var done = plan.update(dt);
  → front Action.update(dt)
  → isCompleted(): loop, dropping front Actions that are done (Action.isDone(worldState):
    their done check, or else all postconditions in the provider's world state);
    true when no Actions are left
```

## Key Design Patterns

1. **`NODE_STATUS` over booleans** — every node returns a three-value Status; RUNNING enables multi-tick behaviours.
2. **`ChildCursor` for resumable composite traversal** — a composite keeps its position across ticks.
3. **`TaskBank` as indirection** — tree structure is decoupled from behaviour; Tasks are registered globally by name.
4. **`AbstractMap` / `AbstractArray` / `AbstractFunc` in public APIs** — JS callers pass plain objects, C# callers native types.
5. **Abstract base nodes** — `CompositeNode`, `DecoratorNode` and `LeafNode` are abstract classes, so a missing `execute()` is a compile error.
