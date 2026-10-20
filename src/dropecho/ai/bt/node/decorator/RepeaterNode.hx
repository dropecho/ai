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
	 * @return Always RUNNING.
	 */
	public function execute():NODE_STATUS {
		child.execute();
		return NODE_STATUS.RUNNING;
	}
}
