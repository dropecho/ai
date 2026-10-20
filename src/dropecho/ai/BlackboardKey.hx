package dropecho.ai;

/**
 * The name of a typed Blackboard value, carrying the value's type `T` at compile time.
 * At runtime it is the plain String name, so JS callers pass strings and nothing extra is generated.
 * Any String converts to a key, so `bb.getValue(("target" : BlackboardKey<Entity>))` and a shared `new BlackboardKey<Entity>("target")` read the same value.
 */
abstract BlackboardKey<T>(String) from String to String {
	/**
	 * Creates a key for the value named `name`.
	 *
	 * @param name - The value's name on the Blackboard.
	 */
	public inline function new(name:String) {
		this = name;
	}
}
