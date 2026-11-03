package dropecho.ai.goap;

/**
 * What the Planner plans for: the Condition names the agent wants true.
 */
@:expose("goap.Goal")
class Goal {
	/** The Condition names that must all be true to reach the Goal. */
	public var conditions(default, null):Array<String>;

	/**
	 * Creates a Goal.
	 *
	 * @param conditions - The Condition names that must all be true.
	 */
	public function new(conditions:Array<String>) {
		this.conditions = conditions;
	}
}
