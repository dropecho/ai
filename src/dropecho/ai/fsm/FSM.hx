package dropecho.ai.fsm;

import dropecho.interop.AbstractFunc.Func_0;
import haxe.ds.ObjectMap;

/** A game-defined yes/no question; when it returns true its Transition is taken. It should only read state. */
typedef Condition = Func_0<Bool>;

/** A move to a target State, taken when its Condition is true. */
@:nativeGen
class Transition {
	/** The State this Transition moves to. */
	public var to(default, null):IState;

	/** The Condition that, when true, takes this Transition. */
	public var condition(default, null):Condition;

	/**
	 * Creates a Transition to `to`, taken when `condition` is true.
	 *
	 * @param to - The target State.
	 * @param condition - The Condition that takes the Transition.
	 */
	public function new(to:IState, condition:Condition) {
		this.to = to;
		this.condition = condition;
	}
}

/**
 * A state machine: holds one current State and changes State when a Transition's Condition becomes true.
 * Call `changeToState` to set the first State before calling `tick`.
 */
@:expose("fsm.FSM")
@:nativeGen
class FSM {
	var _currentState:IState;
	/* Transitions from a given state to another, keyed by the State itself. ObjectMap, because AbstractMap stringifies object keys on JS. */
	var _transitions = new ObjectMap<IState, Array<Transition>>();
	/* Transitions from any state to another */
	var _anyTransitions = new Array<Transition>();

	/** Creates a state machine with no State and no Transitions. */
	public function new() {}

	/**
	 * Ticks the current State, then takes the first Transition whose Condition is true.
	 * Any-transitions are checked before the current State's own Transitions; Transitions to the current State are skipped.
	 * Throws if no State has been set with `changeToState`.
	 */
	public function tick():Void {
		if (_currentState == null) {
			throw "FSM.tick() called before changeToState() — set an initial state first";
		}
		_currentState.tick();

		var transition = getTransition();
		if (transition != null) {
			changeToState(transition.to);
		}
	}

	/**
	 * Gets the State the machine is in.
	 *
	 * @return The current State, or null before the first `changeToState`.
	 */
	public function getCurrentState():IState {
		return _currentState;
	}

	/**
	 * Moves to `state`: calls the current State's `onExit` (if any), then `state.onEnter`.
	 * Runs even if `state` is already current.
	 *
	 * @param state - The State to change to.
	 */
	public function changeToState(state:IState):Void {
		_currentState?.onExit();
		state.onEnter();
		_currentState = state;
	}

	/**
	 * Adds a Transition from `fromState` to `toState`, taken when `condition` is true.
	 * Transitions belong to `fromState` itself, not its name, and are checked in the order they were added.
	 *
	 * @param fromState - The State the Transition leaves from.
	 * @param toState - The State the Transition moves to.
	 * @param condition - The Condition that takes the Transition.
	 */
	public function addTransition(fromState:IState, toState:IState, condition:Condition):Void {
		var transitions = _transitions.get(fromState);
		if (transitions == null) {
			transitions = [];
			_transitions.set(fromState, transitions);
		}
		transitions.push(new Transition(toState, condition));
	}

	/**
	 * Adds an Any-transition to `to`, taken from whatever State is current when `condition` is true.
	 * Any-transitions are checked before the current State's own Transitions, in the order added.
	 *
	 * @param to - The State the Transition moves to.
	 * @param condition - The Condition that takes the Transition.
	 */
	public function addAnyTransition(to:IState, condition:Condition):Void {
		_anyTransitions.push(new Transition(to, condition));
	}

	/**
	 * Finds the Transition the next tick would take: the first one whose Condition is true, any-transitions first.
	 * Transitions to the current State are skipped without asking their Condition, so a State is never re-entered.
	 *
	 * @return The Transition to take, or null if none.
	 */
	private function getTransition():Transition {
		var ownTransitions = _currentState == null ? null : _transitions.get(_currentState);
		for (transitions in [_anyTransitions, ownTransitions]) {
			if (transitions == null) {
				continue;
			}
			for (t in transitions) {
				var leavesCurrentState = t.to != _currentState;
				if (leavesCurrentState && t.condition()) {
					return t;
				}
			}
		}
		return null;
	}

	/**
	 * Draws the State graph as Graphviz DOT: a node per State, labelled with its name, and an edge per Transition, with Any-transitions starting from a node named `any`.
	 * The current State's node has `class="current"`; the Transition the next tick would take has `class="active"` and its target `class="next"`.
	 * To find that Transition it asks the Conditions, as `tick` would, up to the first true one.
	 *
	 * @return The DOT source.
	 */
	public function toDot():String {
		var next = getTransition();
		var nodeIds = new ObjectMap<IState, String>();
		var states = new Array<IState>();
		var edgeLines = new Array<String>();

		function nodeId(state:IState):String {
			var isDeclared = nodeIds.exists(state);
			if (isDeclared == false) {
				nodeIds.set(state, 's${states.length}');
				states.push(state);
			}
			return nodeIds.get(state);
		}

		function addEdges(fromId:String, transitions:Array<Transition>) {
			for (t in transitions) {
				var attributes = t == next ? ' [class="active"]' : "";
				edgeLines.push('  $fromId -> ${nodeId(t.to)}$attributes;');
			}
		}

		addEdges("any", _anyTransitions);
		for (from => transitions in _transitions) {
			addEdges(nodeId(from), transitions);
		}
		// Declared last, so the other States keep their ids when the current State changes.
		if (_currentState != null) {
			nodeId(_currentState);
		}

		var nodeLines = [for (state in states) '  ${nodeIds.get(state)} [${nodeAttributes(state, next)}];'];
		if (_anyTransitions.length > 0) {
			nodeLines.push('  any [label="any", shape=plaintext];');
		}

		return ["digraph {", "  rankdir=LR;"].concat(nodeLines).concat(edgeLines).concat(["}"]).join("\n");
	}

	/**
	 * Builds the DOT attributes of `state`'s node: its quoted name, and its class if it is current or the target of `next`.
	 *
	 * @param state - The State drawn.
	 * @param next - The Transition the next tick would take, or null.
	 * @return The attributes, comma-separated.
	 */
	private function nodeAttributes(state:IState, next:Transition):String {
		var name = StringTools.replace(StringTools.replace(state.getName(), "\\", "\\\\"), '"', '\\"');
		var attributes = ['label="$name"'];
		if (state == _currentState) {
			attributes.push('class="current"');
		}
		var isNextState = next != null && state == next.to;
		if (isNextState) {
			attributes.push('class="next"');
		}
		return attributes.join(", ");
	}
}
