package dropecho.ai.fsm;

import dropecho.interop.AbstractFunc.Func_0;
import dropecho.interop.AbstractMap;

typedef Condition = Func_0<Bool>;

@:nativeGen
class Transition {
	public var to(default, null):IState;
	public var condition(default, null):Condition;

	public function new(to:IState, condition:Condition) {
		this.to = to;
		this.condition = condition;
	}
}

@:expose("fsm.FSM")
@:nativeGen
class FSM {
	var _currentState:IState;
	/* Transitions from a given state to another */
	var _transitions = new AbstractMap<String, Array<Transition>>();
	/* Transitions from any state to another */
	var _anyTransitions = new Array<Transition>();

	public function new() {}

	/**
	 * Updates the current state, and gets any transitions that match.
	 * Given it has a transition, it invokes next.onEnter and current.onExit
	 */
	public function tick() {
		_currentState?.tick();

		var transition = getTransition();
		if (transition != null) {
			changeToState(transition.to);
		}
	}

	/**
	 * @param state - The state to change to. 
	 */
	public function changeToState(state:IState) {
		_currentState?.onExit();
		state.onEnter();
		_currentState = state;
	}

	/**
	 * Add a transition to the FSM.
	 * This condition, when true, changes the FSM from the fromState, to the toState.
	 */
	public function addTransition(fromState:IState, toState:IState, condition:Condition) {
		var t = new Transition(toState, condition);

		var transitions:Array<Transition> = null;

		if (_transitions.exists(fromState.getName())) {
			transitions = _transitions.get(fromState.getName());
		} else {
			transitions = new Array<Transition>();
			_transitions.set(fromState.getName(), transitions);
		}

		transitions.push(t);
	}

	/**
	 * Add a transition to the FSM.
	 * This condition, when true, changes the FSM from ANY state to the toState.
	 */
	public function addAnyTransition(to:IState, condition:Condition) {
		_anyTransitions.push(new Transition(to, condition));
	}

	private function getTransition():Transition {
		for (t in _anyTransitions) {
			if (t.condition()) {
				return t;
			}
		}

		if (!_transitions.exists(_currentState?.getName())) {
			return null;
		}

		var _currentTransitions = _transitions.get(_currentState?.getName());
		if (_currentTransitions != null) {
			for (t in _currentTransitions) {
				if (t.condition()) {
					return t;
				}
			}
		}
		return null;
	}

	public function toDot() {
		var nodeOutput = "";
		var edgeOutput = "";

		var activeTransition = getTransition();
		var activeTransitionName = activeTransition == null ? "" : activeTransition.to.getName();

		nodeOutput = "any\n";

		for (any in _anyTransitions) {
			edgeOutput += '\n any -> ${any.to.getName()}';
			if (activeTransitionName == any.to.getName() && _anyTransitions.contains(activeTransition)) {
				edgeOutput += '[class="active"]';
			}
		}

		for (key => value in _transitions) {
			nodeOutput = nodeOutput + "\n" + key;

			var v:Array<Transition> = value;
			for (edge in v) {
				edgeOutput = edgeOutput + '\n $key -> ${edge.to.getName()}';

				if (activeTransition == edge) {
					edgeOutput += '[class="active"]';
				}
			}
			edgeOutput = edgeOutput + '\n $key -> $key';

			if (key == _currentState.getName()) {
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
