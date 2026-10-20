package dropecho.ai.bt.node.decorator;

/**
 * A Succeeder: succeeds whenever its child finishes, whether the child succeeded or failed.
 */
@:expose("bt.SucceederNode")
class SucceederNode extends DecoratorNode {
	/**
	 * Creates a Succeeder.
	 *
	 * @param child - The node whose failure is ignored.
	 */
	public function new(child:Node) {
		super(child);
	}

	/**
	 * Runs the child once.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return RUNNING while the child is running, otherwise SUCCESS.
	 */
	public function execute(deltaTime:Float):NODE_STATUS {
		var status = executeChild(deltaTime);

		if (status == NODE_STATUS.RUNNING) {
			return NODE_STATUS.RUNNING;
		}

		return NODE_STATUS.SUCCESS;
	}
}
