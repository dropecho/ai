package dropecho.ai.goap;

import dropecho.interop.AbstractArray;
import dropecho.ds.Queue;

class Plan {
	public var _actions(default, null):Queue<Action> = new Queue<Action>();

	public function new(actions:AbstractArray<Action> = null) {
		if (actions != null) {
			_actions.enqueueMany(actions);
		}
	}

	public function update(dT:Float = 0):Bool {
		if (_actions.length > 0) {
			_actions
				.peek()
				.update(dT);
		}

		return isCompleted();
	}

	public function isCompleted():Bool {
		if (_actions.length == 0) {
			return true;
		}

		if (_currentActionIsComplete()) {
			_actions.dequeue();
			return isCompleted();
		}

		return false;
	}

	inline private function _currentActionIsComplete():Bool {
		if (_actions.length > 0) {
			return _actions
				.peek()
				.postconditions_satisfied();
		}
		return true;
	}
}
