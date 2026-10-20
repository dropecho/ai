package dropecho.ai.bt.node.decorator;

/**
 * A Repeater: runs its child every tick and never finishes.
 */
@:expose("bt.RepeaterNode")
class RepeaterNode extends DecoratorNode {
	/**
	 * Creates a Repeater.
	 *
	 * @param child - The node run every tick.
	 */
	public function new(child:Node) {
		super(child);
	}

	/**
	 * Runs the child once, ignoring its Status.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return Always RUNNING.
	 */
	public function execute(deltaTime:Float):NODE_STATUS {
		child.execute(deltaTime);
		return NODE_STATUS.RUNNING;
	}
}
