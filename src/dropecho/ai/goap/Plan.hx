package dropecho.ai.goap;

import dropecho.interop.AbstractArray;
import dropecho.ds.Queue;

/**
 * The Actions to run in order; each update runs the front Action and drops the ones whose done check is true.
 */
@:expose("goap.Plan")
class Plan {
	/** Internal queue of the remaining Actions; use `currentAction` or iterate the Plan instead. */
	public var _actions(default, null):Queue<Action> = new Queue<Action>();

	/** The number of Actions left. */
	public var length(get, null):Int;

	inline function get_length():Int return _actions.length;

	/** The Action running now, or null once the Plan is completed. */
	public var currentAction(get, never):Null<Action>;

	function get_currentAction():Null<Action> {
		var hasActions = _actions.length > 0;
		return hasActions ? _actions.peek() : null;
	}

	/**
	 * Creates a Plan that runs the given Actions in order.
	 *
	 * @param actions - The Actions in the order they run; defaults to none.
	 */
	public function new(actions:AbstractArray<Action> = null) {
		if (actions != null) {
			// Queue.enqueueMany reverses order on JS (dropecho.ds 2.0.0), so enqueue one at a time.
			for (action in actions) {
				_actions.enqueue(action);
			}
		}
	}

	/**
	 * Runs the current Action's update, then drops every finished Action from the front.
	 *
	 * @param dT - The time since the last update, in the game's time unit.
	 * @return True if the Plan is completed.
	 */
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

	/**
	 * Drops finished Actions from the front, by their done check, and says whether none are left.
	 *
	 * @return True if no Actions are left.
	 */
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
