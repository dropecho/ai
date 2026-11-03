package dropecho.ai.bt.node.composite;

/**
 * Another name for `SelectorNode`, as other behavior tree libraries call it.
 */
@:expose("bt.FallbackNode")
class FallbackNode extends SelectorNode {
	/**
	 * Creates a Selector.
	 *
	 * @param children - The children, tried in this order.
	 * @param reactive - Start from the first child every tick, so earlier children are re-checked while a later one is running; defaults to false.
	 */
	public function new(children:Array<Node>, reactive:Bool = false) {
		super(children, reactive);
	}
}
