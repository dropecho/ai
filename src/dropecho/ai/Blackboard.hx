package dropecho.ai;

import dropecho.interop.AbstractMap;

/** The shared facts an agent's AI reads and writes, each a named number. A fact never set reads as 0. */
@:expose("Blackboard")
class Blackboard {
	var _facts = new AbstractMap<String, Float>();

	/** Creates an empty Blackboard. */
	public function new() {}

	/**
	 * Reads a fact.
	 *
	 * @param key - The fact's name.
	 * @return The fact's value, or 0 if it was never set.
	 */
	inline public function get(key:String):Float {
		return _facts.exists(key) ? _facts.get(key) : 0;
	}

	/**
	 * Writes a fact.
	 *
	 * @param key - The fact's name.
	 * @param value - The new value.
	 * @return The new value.
	 */
	inline public function set(key:String, value:Float):Float {
		return _facts.set(key, value);
	}

	/**
	 * Adds 1 to a fact; a fact never set starts from 0.
	 *
	 * @param key - The fact's name.
	 * @return The new value.
	 */
	inline public function increment(key:String):Float {
		return _facts.set(key, get(key) + 1);
	}

	/**
	 * Subtracts 1 from a fact; a fact never set starts from 0.
	 *
	 * @param key - The fact's name.
	 * @return The new value.
	 */
	inline public function decrement(key:String):Float {
		return _facts.set(key, get(key) - 1);
	}

	/**
	 * Lists the facts that have been set, in ascending order of name so every target gives the same order.
	 *
	 * @return A new Array of the fact names; changing it does not change the Blackboard.
	 */
	public function keys():Array<String> {
		var names = [for (name in _facts.keys()) name];
		names.sort(compareNames);
		return names;
	}

	static function compareNames(a:String, b:String):Int {
		if (a < b) {
			return -1;
		}
		if (a > b) {
			return 1;
		}
		return 0;
	}
}
