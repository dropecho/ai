package dropecho.ai.goap;

import dropecho.interop.AbstractArray;
import dropecho.ds.Queue;

class Plan {
	public var _actions(default, null):Queue<Action> = new Queue<Action>();

	public var length(get, null):Int;
	inline function get_length():Int return _actions.length;

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
		while (_actions.length > 0) {
			if (_actions.peek().postconditions_satisfied()) {
				_actions.dequeue();
			} else {
				return false;
			}
		}
		return true;
	}
}
