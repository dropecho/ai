package dropecho.ai.goap;

import dropecho.interop.AbstractFunc.Action_1;
import dropecho.interop.AbstractFunc.Func_0;

/**
 * Something an agent can do: the Planner chains Actions by their conditions and Cost, and a Plan runs them.
 */
@:expose("goap.Action")
class Action {
	/** The Action's name. */
	public var name:String;

	/** The planning Cost, unitless; the Planner picks the Plan with the lowest total. */
	public var cost:Float;

	/** The Condition names that must be true before this Action, used for planning. */
	public var preconditions:Array<String> = new Array<String>();

	/** The Condition names this Action makes true; used for planning, and as the done check when the Action has none of its own. */
	public var postconditions:Array<String> = new Array<String>();

	/** Run on each update while this is the Plan's current Action, with the time since the last update. */
	public var onUpdate:Action_1<Float>;

	/** A game-defined check for whether this Action can start; the library never calls it, and it defaults to always true. */
	public var startCheck:Func_0<Bool> = () -> true;

	/** This Action's own done check, or null to treat the Action as done once all its postconditions are in the current world state. */
	public var doneCheck:Null<Func_0<Bool>> = null;

	/**
	 * Creates an Action.
	 *
	 * @param name - The Action's name.
	 * @param onUpdate - Run on each update while this Action is current, with the time since the last update.
	 * @param cost - The planning Cost (unitless).
	 * @param preconditions - The Condition names needed before this Action, for planning; defaults to none.
	 * @param postconditions - The Condition names this Action makes true; defaults to none.
	 * @param startCheck - The game-defined can-start check; defaults to always true and is not called by the library.
	 * @param doneCheck - The Action's own done check; leave it out to treat the Action as done once its postconditions are in the current world state.
	 */
	public function new(
		name:String,
		onUpdate:Action_1<Float>,
		cost:Float = 0,
		?preconditions:Array<String>,
		?postconditions:Array<String>,
		?startCheck:Func_0<Bool>,
		?doneCheck:Func_0<Bool>
	) {
		this.name = name;
		this.onUpdate = onUpdate;
		this.cost = cost;
		this.preconditions = preconditions ?? this.preconditions;
		this.postconditions = postconditions ?? this.postconditions;
		this.startCheck = startCheck ?? this.startCheck;
		this.doneCheck = doneCheck;
	}

	/**
	 * Asks `startCheck` whether this Action can start; the library never calls this.
	 *
	 * @return True if the Action can start.
	 */
	inline public function canStart():Bool {
		return startCheck();
	}

	/**
	 * Says whether this Action has finished: its own done check if it has one, otherwise
	 * whether all its postconditions are in the given world state.
	 *
	 * @param worldState - The Condition names true in the game right now; only read when the Action has no done check of its own.
	 * @return True if the Action is done.
	 */
	public function isDone(worldState:Array<String>):Bool {
		if (doneCheck != null) {
			return doneCheck();
		}
		for (condition in postconditions) {
			var isMissing = worldState.indexOf(condition) < 0;
			if (isMissing) {
				return false;
			}
		}
		return true;
	}

	/**
	 * Runs `onUpdate` once.
	 *
	 * @param deltaTime - The time since the last update, in the game's time unit.
	 */
	inline public function update(deltaTime:Float):Void {
		onUpdate(deltaTime);
	}
}
