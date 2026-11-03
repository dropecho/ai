package dropecho.ai.bt.node.decorator;

/**
 * Another name for `SucceederNode`, as other behavior tree libraries call it.
 */
@:expose("bt.ForceSuccessNode")
class ForceSuccessNode extends SucceederNode {
	/**
	 * Creates a Succeeder.
	 *
	 * @param child - The node whose failure is ignored.
	 */
	public function new(child:Node) {
		super(child);
	}
}
