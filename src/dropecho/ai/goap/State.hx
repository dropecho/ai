package dropecho.ai.goap;

/**
 * A goal for the Planner: the Condition names the agent wants true.
 */
@:expose("goap.State")
class State {
	/** How much the goal matters; stored but not used by the Planner. */
	public var Relevance(default, null):Int;

	/** The Condition names that must all be true to reach the goal. */
	public var Preconditions(default, null):Array<String>;

	/**
	 * Creates a goal.
	 *
	 * @param preconditions - The Condition names that must all be true.
	 * @param relevance - How much the goal matters; stored but unused.
	 */
	public function new(preconditions:Array<String>, relevance:Int = 0) {
		Relevance = relevance;
		Preconditions = preconditions;
	}
}
