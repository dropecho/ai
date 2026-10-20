package dropecho.ai.bt.node.composite;

/**
 * A reactive Sequence: like a Sequence, but every tick starts again from the first child, so earlier conditions are re-checked while a later child runs.
 *
 * A running child that is preempted is not told; it is simply not ticked again until it is reached again.
 */
@:expose("bt.ReactiveSequenceNode")
class ReactiveSequenceNode extends CompositeNode {
	/**
	 * Creates a reactive Sequence.
	 *
	 * @param children - The children, run in this order.
	 */
	public function new(children:Array<Node>) {
		super(children);
	}

	/**
	 * Runs children from the first one in the same tick: a succeeded child moves on to the next child.
	 *
	 * @return FAILURE when a child fails, SUCCESS when every child succeeds, RUNNING when a child is running (re-checked from the first child next tick).
	 */
	public function execute():NODE_STATUS {
		this.childCursor.reset();
		return runChildren(NODE_STATUS.FAILURE);
	}
}
