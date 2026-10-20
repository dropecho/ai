package dropecho.ai.goap;

import dropecho.interop.AbstractArray;
import dropecho.ds.Queue;

/**
 * The Actions to run in order; each update runs the front Action and drops the ones that are done.
 * An Action with its own done check is done when that check says so; one without is done when all
 * its postconditions are in the world state the Plan's world state provider returns.
 */
@:expose("goap.Plan")
class Plan {
	private var _actions:Queue<Action> = new Queue<Action>();
	private var _worldState:Null<WorldStateProvider>;

	/**
	 * Creates a Plan that runs the given Actions in order.
	 * Throws if an Action has no done check of its own and no world state provider is given.
	 *
	 * @param actions - The Actions in the order they run; defaults to none.
	 * @param worldState - Returns the Condition names true in the game right now; needed by Actions without their own done check.
	 */
	public function new(actions:AbstractArray<Action> = null, ?worldState:WorldStateProvider) {
		_worldState = worldState;
		if (actions != null) {
			// Queue.enqueueMany reverses order on JS (dropecho.ds 2.0.0), so enqueue one at a time.
			for (action in actions) {
				_requireWayToFinish(action);
				_actions.enqueue(action);
			}
		}
	}

	/**
	 * Runs the current Action's update, then drops every finished Action from the front.
	 *
	 * @param deltaTime - The time since the last update, in the game's time unit.
	 * @return True if the Plan is completed.
	 */
	public function update(deltaTime:Float = 0):Bool {
		if (_actions.length > 0) {
			_actions
				.peek()
				.update(deltaTime);
		}

		return isCompleted();
	}

	/**
	 * Gives the Action running now, without dropping finished ones first.
	 *
	 * @return The front Action, or null once no Actions are left.
	 */
	public function currentAction():Null<Action> {
		var hasActions = _actions.length > 0;
		return hasActions ? _actions.peek() : null;
	}

	/**
	 * Counts the Actions left, without dropping finished ones first.
	 *
	 * @return The number of remaining Actions.
	 */
	public function length():Int {
		return _actions.length;
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
	 * Copies the remaining Actions into a new Array, in the order they will run; works from every target.
	 *
	 * @return The remaining Actions; changing the Array does not change the Plan.
	 */
	public function remainingActions():Array<Action> {
		return [for (action in _actions) action];
	}

	/**
	 * Drops finished Actions from the front and says whether none are left; asks the world state provider at most once per call.
	 *
	 * @return True if no Actions are left.
	 */
	public function isCompleted():Bool {
		var worldState:Null<Array<String>> = null;
		while (_actions.length > 0) {
			var action = _actions.peek();
			var needsWorldState = action.doneCheck == null && worldState == null;
			if (needsWorldState) {
				worldState = _currentWorldState();
			}
			if (action.isDone(worldState)) {
				_actions.dequeue();
			} else {
				return false;
			}
		}
		return true;
	}

	private function _currentWorldState():Array<String> {
		return _worldState != null ? _worldState() : [];
	}

	private function _requireWayToFinish(action:Action):Void {
		var cannotTellWhenDone = action.doneCheck == null && _worldState == null;
		if (cannotTellWhenDone) {
			throw 'Action "${action.name}" has no done check and the Plan has no world state provider, so it can never tell when the Action is done. '
				+ 'Either pass a world state provider, a function returning the Condition names true right now, to the Planner or Plan '
				+ '(new Planner(goal, actions, () -> currentConditions())), or give the Action its own done check as the last constructor argument '
				+ '(new Action("${action.name}", onUpdate, cost, preconditions, postconditions, null, () -> isFinished())).';
		}
	}
}
