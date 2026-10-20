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
	 * @param reactive - Start from the first child every tick, so earlier children are re-checked while a later one is running; defaults to false.
	 */
	public function new(children:Array<Node>, reactive:Bool = false) {
		super(children, reactive);
	}

	/**
	 * Runs children from the current one in the same tick: a succeeded child moves on to the next child, and a running child is resumed next tick.
	 *
	 * @return FAILURE when a child fails, SUCCESS when every child from the current one succeeds (both return to the first child), RUNNING when a child is running.
	 */
	public function execute():NODE_STATUS {
		return runChildren(NODE_STATUS.FAILURE);
	}
}
