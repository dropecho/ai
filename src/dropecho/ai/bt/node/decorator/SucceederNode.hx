package dropecho.ai.bt.node.decorator;

/**
 * A Succeeder: succeeds whenever its child finishes, whether the child succeeded or failed.
 */
@:expose("bt.SucceederNode")
class SucceederNode extends DecoratorNode {
	/**
	 * Creates a Succeeder.
	 *
	 * @param child - The node whose failure is ignored.
	 */
	public function new(child:Node) {
		super(child);
	}

	/**
	 * Runs the child once.
	 *
	 * @return RUNNING while the child is running, otherwise SUCCESS.
	 */
	public function execute():NODE_STATUS {
		var status = child.execute();

		if (status == NODE_STATUS.RUNNING) {
			return NODE_STATUS.RUNNING;
		}

		return NODE_STATUS.SUCCESS;
	}
}
