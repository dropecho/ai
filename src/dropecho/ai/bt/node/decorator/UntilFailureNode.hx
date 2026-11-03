package dropecho.ai.bt.node.decorator;

/**
 * Another name for `RepeatUntilNode` (Repeat until fail), as other behavior tree libraries call it.
 */
@:expose("bt.UntilFailureNode")
class UntilFailureNode extends RepeatUntilNode {
	/**
	 * Creates a Repeat until fail.
	 *
	 * @param child - The node repeated until it fails.
	 */
	public function new(child:Node) {
		super(child);
	}
}
