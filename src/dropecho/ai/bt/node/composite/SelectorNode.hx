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
	 * Runs children from the current one in the same tick: a failed child moves on to the next child, and a running child is resumed next tick.
	 *
	 * @return SUCCESS when a child succeeds, FAILURE when every child from the current one fails (both return to the first child), RUNNING when a child is running.
	 */
	public function execute():NODE_STATUS {
		while (true) {
			var childStatus = this.childIterator
				.current()
				.execute();

			if (childStatus == NODE_STATUS.RUNNING) {
				return NODE_STATUS.RUNNING;
			}

			var isLastChild = this.childIterator.hasNext() == false;
			if (childStatus == NODE_STATUS.SUCCESS || isLastChild) {
				this.childIterator.reset();
				return childStatus;
			}

			this.childIterator.next();
		}
	}
}
