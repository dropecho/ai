package dropecho.ai.bt.node.decorator;

/**
 * A Force failure: fails whenever its child finishes, whether the child succeeded or failed; the mirror of `SucceederNode`.
 */
@:expose("bt.ForceFailureNode")
class ForceFailureNode extends DecoratorNode {
	/**
	 * Creates a Force failure.
	 *
	 * @param child - The node whose success is ignored.
	 */
	public function new(child:Node) {
		super(child);
	}

	/**
	 * Runs the child once.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return RUNNING while the child is running, otherwise FAILURE.
	 */
	public function execute(deltaTime:Float):NODE_STATUS {
		var status = executeChild(deltaTime);

		if (status == NODE_STATUS.RUNNING) {
			return NODE_STATUS.RUNNING;
		}

		return NODE_STATUS.FAILURE;
	}
}
