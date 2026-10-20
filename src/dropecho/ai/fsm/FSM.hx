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
	 * Any-transitions are checked before the current State's own Transitions.
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
		var t = new Transition(toState, condition);

		var transitions:Array<Transition> = null;

		if (_transitions.exists(fromState)) {
			transitions = _transitions.get(fromState);
		} else {
			transitions = new Array<Transition>();
			_transitions.set(fromState, transitions);
		}

		transitions.push(t);
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

	private function getTransition():Transition {
		for (t in _anyTransitions) {
			if (t.condition()) {
				return t;
			}
		}

		if (_currentState == null) {
			return null;
		}

		var currentStateHasTransitions = _transitions.exists(_currentState);
		if (currentStateHasTransitions == false) {
			return null;
		}

		var _currentTransitions = _transitions.get(_currentState);
		if (_currentTransitions != null) {
			for (t in _currentTransitions) {
				if (t.condition()) {
					return t;
				}
			}
		}
		return null;
	}

	/**
	 * Draws the State graph as Graphviz DOT, marking the current State and the Transition about to be taken with `class="active"`.
	 * It calls every Condition up to the first true one to find that Transition.
	 * Only States with their own Transitions appear as nodes; Any-transitions start from a node named `any`.
	 *
	 * @return The DOT source.
	 */
	public function toDot():String {
		var nodeOutput = "";
		var edgeOutput = "";

		var activeTransition = getTransition();
		var activeTransitionName = activeTransition == null ? "" : activeTransition.to.getName();

		if (_anyTransitions.length > 0) {
			nodeOutput = "any\n";
			for (any in _anyTransitions) {
				edgeOutput += '\n any -> ${any.to.getName()}';
				var isActiveAnyTransition = activeTransitionName == any.to.getName() && _anyTransitions.contains(activeTransition);
				if (isActiveAnyTransition) {
					edgeOutput += '[class="active"]';
				}
			}
		}

		for (state => value in _transitions) {
			var key = state.getName();
			nodeOutput = nodeOutput + "\n" + key;

			var v:Array<Transition> = value;
			for (edge in v) {
				edgeOutput = edgeOutput + '\n $key -> ${edge.to.getName()}';

				if (activeTransition == edge) {
					edgeOutput += '[class="active"]';
				}
			}
			edgeOutput = edgeOutput + '\n $key -> $key';

			var isCurrentState = state == _currentState;
			if (isCurrentState) {
				if (activeTransition == null) {
					nodeOutput += '[class="active"]';
					edgeOutput += '[class="active"]';
				}
			} else {
				if (activeTransitionName == key) {
					nodeOutput += '[class="active"]';
				}
			}
		}

		return '
      digraph {
        rankdir=LR

        ${nodeOutput}
        ${edgeOutput}
      }
    ';

	}
}
