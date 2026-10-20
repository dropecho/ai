package dropecho.ai.utility;

import haxe.Json;

using Lambda;

/** A named need of a Utility agent; the lower its value, the more urgent it is. */
@:expose("utility.Motive")
class Motive {
	/** The Motive's name. */
	public var name:String;

	/** How satisfied the need is; lower means more urgent. */
	public var value:Float;

	/**
	 * Creates a Motive.
	 *
	 * @param name - The Motive's name.
	 * @param value - Its starting value; lower means more urgent.
	 */
	public function new(name:String, value:Float) {
		this.name = name;
		this.value = value;
	}
}

/** A Utility agent: picks the most urgent of its Motives. */
@:expose("utility.UtilityAgent")
class UtilityAgent {
	/** The agent's Motives; game code adds to and updates them directly. */
	public var motives:Array<Motive> = new Array<Motive>();

	/** Creates a Utility agent with no Motives. */
	public function new() {}

	/**
	 * Finds the Motive with the lowest value; on a tie the earlier Motive in `motives` wins.
	 *
	 * @return The most urgent Motive, or null if there are none.
	 */
	public function getMostImportantMotive():Null<Motive> {
		return motives.fold(foldToLowestMotive, null);
	}

	inline private function foldToLowestMotive(motive:Motive, result:Motive):Motive {
		var isResultAtLeastAsUrgent = result != null && result.value <= motive.value;
		if (isResultAtLeastAsUrgent) {
			return result;
		}
		return motive;
	}

	/**
	 * Describes the agent's Motives.
	 *
	 * @return The Motives as indented JSON.
	 */
	inline public function toString():String {
		return Json.stringify(motives, null, "  ");
	}
}
