package dropecho.ai.bt.node.composite;

/**
 * A reactive Selector: like a Selector, but every tick starts again from the first child, so a higher-priority child can take over from a running one.
 *
 * A running child that is preempted is not told; it is simply not ticked again until it is reached again.
 */
@:expose("bt.ReactiveSelectorNode")
class ReactiveSelectorNode extends CompositeNode {
	/**
	 * Creates a reactive Selector.
	 *
	 * @param children - The children, tried in this order (highest priority first).
	 */
	public function new(children:Array<Node>) {
		super(children);
	}

	/**
	 * Runs children from the first one in the same tick: a failed child moves on to the next child.
	 *
	 * @return SUCCESS when a child succeeds, FAILURE when every child fails, RUNNING when a child is running (re-checked from the first child next tick).
	 */
	public function execute():NODE_STATUS {
		this.childCursor.reset();
		return runChildren(NODE_STATUS.SUCCESS);
	}
}
