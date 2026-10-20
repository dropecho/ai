package dropecho.ai.bt.node.composite;

/**
 * A Selector: succeeds at the first child that succeeds, and fails if every child fails.
 */
@:expose("bt.SelectorNode")
class SelectorNode extends CompositeNode {
	/**
	 * Creates a Selector.
	 *
	 * @param children - The children, tried in this order.
	 */
	public function new(children:Array<Node>) {
		super(children);
	}

	/**
	 * Runs the current child once; a failed child that is not the last moves the cursor to the next child, run on the next tick.
	 *
	 * @return SUCCESS when a child succeeds, FAILURE when the last child fails (both return to the first child), otherwise RUNNING.
	 */
	public function execute():NODE_STATUS {
		var status = this.childIterator
			.current()
			.execute();

		if (status == NODE_STATUS.SUCCESS) {
			this.childIterator.reset();
			return NODE_STATUS.SUCCESS;
		}

		if (status == NODE_STATUS.FAILURE) {
			var isOnLastChild = this.childIterator.hasNext() == false;
			if (isOnLastChild) {
				this.childIterator.reset();
				return NODE_STATUS.FAILURE;
			}

			this.childIterator.next();
		}

		return NODE_STATUS.RUNNING;
	}
}
