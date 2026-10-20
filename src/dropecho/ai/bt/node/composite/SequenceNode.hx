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
	 * Runs children from the current one in the same tick: a succeeded child moves on to the next child, and a running child is resumed next tick.
	 *
	 * @return FAILURE when a child fails, SUCCESS when every child from the current one succeeds (both return to the first child), RUNNING when a child is running.
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
			if (childStatus == NODE_STATUS.FAILURE || isLastChild) {
				this.childIterator.reset();
				return childStatus;
			}

			this.childIterator.next();
		}
	}
}
