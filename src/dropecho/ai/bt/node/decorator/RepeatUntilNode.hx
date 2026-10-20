package dropecho.ai.bt.node.decorator;

/**
 * A Repeat until fail: runs its child every tick until the child fails.
 */
@:expose("bt.RepeatUntilNode")
class RepeatUntilNode extends DecoratorNode {
	/**
	 * Creates a Repeat until fail.
	 *
	 * @param child - The node repeated until it fails.
	 */
	public function new(child:Node) {
		super(child);
	}

	/**
	 * Runs the child once.
	 *
	 * @return SUCCESS if the child failed, otherwise RUNNING.
	 */
	public function execute():NODE_STATUS {
		var status = child.execute();

		var keepRepeating = status == NODE_STATUS.SUCCESS || status == NODE_STATUS.RUNNING;
		if (keepRepeating) {
			return NODE_STATUS.RUNNING;
		}

		return NODE_STATUS.SUCCESS;
	}
}
