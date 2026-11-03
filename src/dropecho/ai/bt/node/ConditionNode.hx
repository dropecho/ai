package dropecho.ai.bt.node;

import dropecho.ai.Blackboard;

/**
 * A Condition leaf: asks a Check each tick and succeeds when it is true, fails when it is false.
 *
 * It never returns RUNNING, so it is never halted.
 */
@:expose("bt.ConditionNode")
class ConditionNode implements Node {
	private var check:Check;
	private var context:Blackboard;

	/**
	 * Creates a Condition leaf.
	 *
	 * @param check - The question asked each tick, given the Blackboard.
	 */
	public function new(check:Check) {
		this.check = check;
	}

	/**
	 * Stores the Blackboard that the Check is given each tick.
	 *
	 * @param context - The Blackboard shared by every node in the tree.
	 */
	public function init(context:Blackboard):Void {
		this.context = context;
	}

	/**
	 * Asks the Check once.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit; unused.
	 * @return SUCCESS if the Check is true, FAILURE if it is false.
	 */
	public function execute(deltaTime:Float):NODE_STATUS {
		var isTrue = check(this.context);
		return isTrue ? NODE_STATUS.SUCCESS : NODE_STATUS.FAILURE;
	}

	/**
	 * Does nothing: a Condition never returns RUNNING.
	 */
	public function halt():Void {}
}
