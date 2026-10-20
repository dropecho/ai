package dropecho.ai.bt.node.composite;

/**
 * A Sequence: fails at the first child that fails, and succeeds if every child succeeds.
 */
@:expose("bt.SequenceNode")
class SequenceNode extends CompositeNode {
	/**
	 * Creates a Sequence.
	 *
	 * @param children - The children, run in this order.
	 */
	public function new(children:Array<Node>) {
		super(children);
	}

	/**
	 * Runs the current child once; a succeeded child that is not the last moves the cursor to the next child, run on the next tick.
	 *
	 * @return FAILURE when a child fails, SUCCESS when the last child succeeds (both return to the first child), otherwise RUNNING.
	 */
	public function execute():NODE_STATUS {
		var childStatus = this.childIterator
			.current()
			.execute();

		if (childStatus == NODE_STATUS.RUNNING) {
			return NODE_STATUS.RUNNING;
		}

		var childFailed = (childStatus == NODE_STATUS.FAILURE);
		var allChildrenSucceeded = this.childIterator.hasNext() == false && childStatus == NODE_STATUS.SUCCESS;

		if (childFailed || allChildrenSucceeded) {
			this.childIterator.reset();
			return childStatus;
		}

		this.childIterator.next();
		return NODE_STATUS.RUNNING;
	}
}
