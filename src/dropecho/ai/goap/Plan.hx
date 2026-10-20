package dropecho.ai.goap;

import dropecho.interop.AbstractArray;
import dropecho.ds.Queue;

class Plan {
	public var _actions(default, null):Queue<Action> = new Queue<Action>();

	public var length(get, null):Int;
	inline function get_length():Int return _actions.length;

	/** The Action running now, or null once the Plan is completed. */
	public var currentAction(get, never):Null<Action>;

	function get_currentAction():Null<Action> {
		var hasActions = _actions.length > 0;
		return hasActions ? _actions.peek() : null;
	}

	public function new(actions:AbstractArray<Action> = null) {
		if (actions != null) {
			// Queue.enqueueMany reverses order on JS (dropecho.ds 2.0.0), so enqueue one at a time.
			for (action in actions) {
				_actions.enqueue(action);
			}
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

	/**
	 * Iterates the remaining Actions in the order they will run.
	 *
	 * @return An iterator over the remaining Actions.
	 */
	public function iterator():Iterator<Action> {
		return _actions.iterator();
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
