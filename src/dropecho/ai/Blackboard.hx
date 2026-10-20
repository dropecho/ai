package dropecho.ai;

import dropecho.interop.AbstractFunc.Action_0;
import dropecho.interop.AbstractFunc.Action_1;
import dropecho.interop.AbstractMap;

/** A game-defined function told the name of a Blackboard fact or value that just changed. */
typedef ChangeListener = Action_1<String>;

/**
 * The shared facts an agent's AI reads and writes. A fact is a named number and reads as 0 if never set.
 * A value is a named piece of data of any type, read and written through a typed `BlackboardKey`, and reads as null if never set.
 * Facts and values are separate: the same name can hold both, and `onChange` listeners for that name hear about either.
 */
@:expose("Blackboard")
class Blackboard {
	var _facts = new AbstractMap<String, Float>();
	/* Any, because each key fixes its own value type; getValue gets it back as the key's T. */
	var _values = new AbstractMap<String, Any>();
	var _listeners = new AbstractMap<String, Array<ChangeSubscription>>();

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
	 * Writes a fact; `onChange` listeners for `key` are told if the value read by `get` changes.
	 *
	 * @param key - The fact's name.
	 * @param value - The new value.
	 * @return The new value.
	 */
	public function set(key:String, value:Float):Float {
		var isChange = get(key) != value;
		_facts.set(key, value);
		if (isChange) {
			notifyChange(key);
		}
		return value;
	}

	/**
	 * Adds 1 to a fact; a fact never set starts from 0.
	 *
	 * @param key - The fact's name.
	 * @return The new value.
	 */
	public function increment(key:String):Float {
		return set(key, get(key) + 1);
	}

	/**
	 * Subtracts 1 from a fact; a fact never set starts from 0.
	 *
	 * @param key - The fact's name.
	 * @return The new value.
	 */
	public function decrement(key:String):Float {
		return set(key, get(key) - 1);
	}

	/**
	 * Lists the facts that have been set, in ascending order of name so every target gives the same order.
	 * Values are not included; see `valueKeys`.
	 *
	 * @return A new Array of the fact names; changing it does not change the Blackboard.
	 */
	public function keys():Array<String> {
		return sortedNames([for (name in _facts.keys()) name]);
	}

	/**
	 * Reads a value.
	 *
	 * @param key - The value's key; in JS, its name as a string.
	 * @return The value, or null if it was never set or was removed (on C#, `default(T)` when `T` is a value type).
	 */
	public function getValue<T>(key:BlackboardKey<T>):T {
		return readValue(key);
	}

	/**
	 * Writes a value; `onChange` listeners for `key` are told if it is not `==` to the value there before.
	 * Objects compare by reference, so writing a changed object back in place does not count as a change.
	 *
	 * @param key - The value's key; in JS, its name as a string.
	 * @param value - The new value.
	 * @return The new value.
	 */
	public function setValue<T>(key:BlackboardKey<T>, value:T):T {
		var previous = readValue(key);
		var isChange = previous != (value : Any);
		_values.set(key, value);
		if (isChange) {
			notifyChange(key);
		}
		return value;
	}

	/**
	 * Tells whether a value has been set and not removed, even if it was set to null.
	 *
	 * @param key - The value's key; in JS, its name as a string.
	 * @return True if the Blackboard holds a value for `key`.
	 */
	public function hasValue<T>(key:BlackboardKey<T>):Bool {
		return _values.exists(key);
	}

	/**
	 * Removes a value, so it reads as null again; `onChange` listeners for `key` are told if it was not null.
	 *
	 * @param key - The value's key; in JS, its name as a string.
	 * @return True if there was a value to remove.
	 */
	public function removeValue<T>(key:BlackboardKey<T>):Bool {
		var previous = readValue(key);
		var wasHeld = _values.remove(key);
		if (previous != null) {
			notifyChange(key);
		}
		return wasHeld;
	}

	/**
	 * Lists the values that are held, in ascending order of name so every target gives the same order.
	 *
	 * @return A new Array of the value names; changing it does not change the Blackboard.
	 */
	public function valueKeys():Array<String> {
		return sortedNames([for (name in _values.keys()) name]);
	}

	/**
	 * Calls `listener` with `key` after the fact or value named `key` changes, in the order listeners were added.
	 * Listeners may be added or removed while listeners are being called: one added then waits for the next change, one removed is not called again.
	 *
	 * @param key - The name of the fact or value to watch.
	 * @param listener - Called with `key` after each change.
	 * @return A function that removes this listener; calling it again does nothing.
	 */
	public function onChange(key:String, listener:ChangeListener):Action_0 {
		var subscription = new ChangeSubscription(listener);
		var isFirstListener = _listeners.exists(key) == false;
		if (isFirstListener) {
			_listeners.set(key, []);
		}
		_listeners.get(key).push(subscription);
		return () -> removeSubscription(key, subscription);
	}

	function removeSubscription(key:String, subscription:ChangeSubscription):Void {
		subscription.isActive = false;
		var subscriptions = listenersOf(key);
		subscriptions.remove(subscription);
		if (subscriptions.length == 0) {
			_listeners.remove(key);
		}
	}

	function notifyChange(key:String):Void {
		for (subscription in listenersOf(key).copy()) {
			if (subscription.isActive) {
				subscription.listener(key);
			}
		}
	}

	function readValue(key:String):Any {
		return _values.exists(key) ? _values.get(key) : null;
	}

	function listenersOf(key:String):Array<ChangeSubscription> {
		return _listeners.exists(key) ? _listeners.get(key) : [];
	}

	static function sortedNames(names:Array<String>):Array<String> {
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

private class ChangeSubscription {
	public final listener:ChangeListener;
	public var isActive = true;

	public function new(listener:ChangeListener) {
		this.listener = listener;
	}
}
