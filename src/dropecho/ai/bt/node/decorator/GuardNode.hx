package dropecho.ai.bt.node.decorator;

import dropecho.ai.bt.node.Check;

/**
 * A Guard (precondition): runs its child only while a Check is true.
 *
 * The Check is asked every tick, also while the child is RUNNING; when it turns false the running child is halted.
 */
@:expose("bt.GuardNode")
class GuardNode extends DecoratorNode {
	private var check:Check;
	private var isChildRunning:Bool = false;

	/**
	 * Creates a Guard.
	 *
	 * @param check - The precondition asked each tick, given the Blackboard.
	 * @param child - The node run while the Check is true.
	 */
	public function new(check:Check, child:Node) {
		super(child);
		this.check = check;
	}

	/**
	 * Asks the Check, then runs the child if it is true.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return FAILURE if the Check is false (a running child is halted), otherwise the child's Status.
	 */
	public function execute(deltaTime:Float):NODE_STATUS {
		var isAllowed = check(this.context);
		if (isAllowed == false) {
			halt();
			return NODE_STATUS.FAILURE;
		}

		var status = this.child.execute(deltaTime);
		isChildRunning = status == NODE_STATUS.RUNNING;
		return status;
	}

	/**
	 * Halts the child if it is running.
	 */
	override public function halt():Void {
		if (isChildRunning) {
			super.halt();
		}
		isChildRunning = false;
	}
}
