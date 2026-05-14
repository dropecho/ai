# Architecture — dropecho.ai

## Source Layout

```
src/dropecho/ai/
├── Blackboard.hx              # Shared key→Int context passed through BT
├── TaskBank.hx                # Static task registry (String → Blackboard → NODE_STATUS)
├── bt/
│   ├── BehaviorTree.hx        # Root BT node; holds Blackboard, delegates to child
│   └── node/
│       ├── Node.hx            # Node interface + IExecutable<T> interface
│       ├── NODE_STATUS.hx     # Enum abstract: SUCCESS=0, FAILURE=1, RUNNING=2
│       ├── LeafNode.hx        # Stub (commented out — not implemented)
│       ├── TaskNode.hx        # Leaf node that calls a named TaskBank task
│       ├── composite/
│       │   ├── CompositeNode.hx   # Base: holds Array<Node>, CurrentIterator
│       │   ├── SelectorNode.hx    # OR logic — first success wins
│       │   └── SequenceNode.hx    # AND logic — first failure stops
│       └── decorator/
│           ├── DecoratorNode.hx   # Base: wraps single child Node
│           ├── InverterNode.hx    # Flips SUCCESS↔FAILURE
│           ├── RepeaterNode.hx    # Always returns RUNNING
│           ├── RepeatUntilNode.hx # Runs until child FAILURE, returns SUCCESS
│           └── SucceederNode.hx   # Always returns SUCCESS (unless RUNNING)
├── fsm/
│   ├── FSM.hx                 # State machine: tick(), transitions, toDot()
│   └── IState.hx              # State interface: getName, onEnter, onExit, tick
├── goap/
│   ├── Action.hx              # Action: cost, pre/postconditions, update function
│   ├── Plan.hx                # Ordered Queue<Action>; ticks and dequeues on completion
│   ├── Planner.hx             # Backward-chaining plan generator
│   └── State.hx               # Goal state: preconditions + relevance
└── utility/
    ├── Motive.hx              # name + Float value; lowest = most important
    └── (UtilityAgent in Motive.hx)  # holds motives, finds getMostImportantMotive()

src/dropecho/util/
├── CurrentIterator.hx         # Array iterator with current()/reset() — used by CompositeNode
└── NotImplementedException.hx # Thrown by base nodes (CompositeNode, DecoratorNode)
```

## Core Class Responsibilities

### `Blackboard` (`src/dropecho/ai/Blackboard.hx`)
Shared context passed to every BT node on `init()`. Stores integer facts by string key. Provides `get`, `set`, `increment`, `decrement`. Uses `AbstractMap<String, Int>` for cross-platform compatibility.

### `TaskBank` (`src/dropecho/ai/TaskBank.hx`)
Static registry mapping task names (strings) to `Task` functions (`Blackboard → NODE_STATUS`). Users register tasks with `TaskBank.register(name, fn)` before building a tree. `TaskNode` looks up and calls tasks by name at execute time.

### `BehaviorTree` (`src/dropecho/ai/bt/BehaviorTree.hx`)
The user-facing entry point for behavior trees. Wraps a single root `Node`. `init(context)` propagates the `Blackboard` down the tree. `execute()` delegates to the root node and returns its status.

### `CompositeNode` (`src/dropecho/ai/bt/node/composite/CompositeNode.hx`)
Base for multi-child nodes. Stores `Array<Node>` and a `CurrentIterator<Node>` for position tracking. `init()` propagates context to all children. Subclasses implement `execute()` with their own selection logic.

### `SelectorNode`
Tries children in order using `childIterator`. On SUCCESS: resets iterator, returns SUCCESS. On FAILURE: advances to next child; if no more children, resets and returns FAILURE. Otherwise returns RUNNING.

### `SequenceNode`
Runs children in order. On RUNNING: stays. On FAILURE or all-SUCCESS (no more children): resets iterator and returns status. Otherwise advances to next and returns RUNNING.

### `DecoratorNode` (`src/dropecho/ai/bt/node/decorator/DecoratorNode.hx`)
Base for single-child wrapper nodes. Propagates `init()` to the child. Subclasses override `execute()`.

### `FSM` (`src/dropecho/ai/fsm/FSM.hx`)
Holds the current `IState` and two transition tables: per-state transitions (`_transitions: AbstractMap<String, Array<Transition>>`) and global transitions (`_anyTransitions: Array<Transition>`). `tick()` runs current state then checks for a matching transition (any-transitions checked first). On match, calls `onExit()` on current and `onEnter()` on new state.

### `Planner` (`src/dropecho/ai/goap/Planner.hx`)
Backward-chaining planner. Given a `State` goal and `Array<Action>` sorted by cost, iterates goal preconditions and finds the cheapest action whose postconditions satisfy each. Recursively adds that action's preconditions to the worklist. Returns a `Plan` or `null` if unsatisfiable.

### `Plan` (`src/dropecho/ai/goap/Plan.hx`)
Wraps a `Queue<Action>`. `update(dT)` ticks the front action. `isCompleted()` recursively dequeues actions whose `postconditions_satisfied()` returns true; returns `true` when the queue is empty.

## Behavior Tree Execution Flow

```
user: tree.init(blackboard)
  → BehaviorTree.init(context)
    → child.init(context)            # recurses through composite/decorator chains
      → TaskNode.init(context)       # stores context for use in execute()

user: tree.execute()  (called every game tick)
  → BehaviorTree.execute()
    → child.execute()
      → CompositeNode / DecoratorNode.execute()
        → childIterator.current().execute()   # or child.execute() for decorators
          → TaskNode.execute()
            → TaskBank.get(name)(context)     # user-defined task function
            → returns NODE_STATUS
```

## FSM Execution Flow

```
user: fsm.tick()
  → _currentState.tick()            # run current state logic
  → getTransition()                 # check _anyTransitions first, then _transitions[currentName]
  → if transition found:
      _currentState.onExit()
      transition.to.onEnter()
      _currentState = transition.to
```

## GOAP Execution Flow

```
var planner = new Planner(goalState, availableActions)
var plan = planner.generatePlan()
  → start with goal.Preconditions as worklist
  → while worklist not empty:
      findBestMatch(precondition) → lowest-cost Action whose Postconditions contain precondition
      plan.unshift(action)
      prepend action.Preconditions to worklist
  → return Plan(orderedActions)

// per game tick:
var done = plan.update(deltaTime)
  → peek front action, call action.update(dT)
  → isCompleted() dequeues actions whose postconditions are satisfied
```

## Key Design Patterns

1. **`NODE_STATUS` over booleans** — all BT nodes return a three-value status; RUNNING enables multi-frame behaviors
2. **`CurrentIterator` for resumable composite traversal** — stores position across ticks without re-scanning from index 0
3. **`TaskBank` as indirection layer** — decouples tree structure from behavior implementation; tasks registered globally
4. **`AbstractMap` / `AbstractFunc` everywhere** — JS callers pass plain objects, C# callers pass native types
5. **`NotImplementedException` on base nodes** — `CompositeNode.execute()` and `DecoratorNode.execute()` throw; forces subclass override
