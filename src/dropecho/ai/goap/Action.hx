package dropecho.ai.goap;

import dropecho.interop.AbstractFunc.Action_1;
import dropecho.interop.AbstractFunc.Func_0;

/**
 * Something an agent can do: the Planner chains Actions by their conditions and Cost, and a Plan runs them.
 */
@:expose("goap.Action")
class Action {
	/** The Action's name. */
	public var ActionType:String;

	/** The planning cost, unitless; the Planner picks the Plan with the lowest total. */
	public var Cost:Float;

	/** The Condition names that must be true before this Action, used only for planning. */
	public var Preconditions:Array<String> = new Array<String>();

	/** The Condition names this Action makes true, used only for planning. */
	public var Postconditions:Array<String> = new Array<String>();

	/** The function run on each update while this is the Plan's current Action. */
	public var UpdateFunc:Action_1<Float>;

	/** A game-defined check for whether this Action can start; the library never calls it, and it defaults to always true. */
	public var PreMatcher:Func_0<Bool> = () -> true;

	/** This Action's own done check, or null to treat the Action as done once all its postconditions are in the current world state. */
	public var PostMatcher:Null<Func_0<Bool>> = null;

	/**
	 * Creates an Action.
	 *
	 * @param actionType - The Action's name.
	 * @param updateFunc - The function run on each update while this Action is current.
	 * @param cost - The planning cost (unitless).
	 * @param preconditions - The Condition names needed before this Action, for planning; defaults to none.
	 * @param postconditions - The Condition names this Action makes true, for planning; defaults to none.
	 * @param preMatcher - The game-defined can-start check; defaults to always true and is not called by the library.
	 * @param postMatcher - The Action's own done check; leave it out to treat the Action as done once its postconditions are in the current world state.
	 */
	public function new(
		actionType:String,
		updateFunc:Float->Void,
		cost:Float = 0,
		?preconditions:Array<String>,
		?postconditions:Array<String>,
		?preMatcher:Func_0<Bool>,
		?postMatcher:Func_0<Bool>
	) {
		ActionType = actionType;
		UpdateFunc = updateFunc;
		Cost = cost;
		Preconditions = preconditions ?? Preconditions;
		Postconditions = postconditions ?? Postconditions;
		PreMatcher = preMatcher ?? PreMatcher;
		PostMatcher = postMatcher;
	}

	/**
	 * Asks `PreMatcher` whether this Action can start; the library never calls this.
	 *
	 * @return True if the Action can start.
	 */
	inline public function preconditions_satisfied():Bool {
		return PreMatcher();
	}

	/**
	 * Says whether this Action has finished: its own done check if it has one, otherwise
	 * whether all its postconditions are in the given world state.
	 *
	 * @param worldState - The Condition names true in the game right now; only read when the Action has no done check of its own.
	 * @return True if the Action is done.
	 */
	public function postconditions_satisfied(worldState:Array<String>):Bool {
		if (PostMatcher != null) {
			return PostMatcher();
		}
		for (condition in Postconditions) {
			var isMissing = worldState.indexOf(condition) < 0;
			if (isMissing) {
				return false;
			}
		}
		return true;
	}

	/**
	 * Runs the Action's update function once.
	 *
	 * @param delta_time - The time since the last update, in the game's time unit.
	 */
	inline public function update(delta_time:Float):Void {
		UpdateFunc(delta_time);
	}
}
