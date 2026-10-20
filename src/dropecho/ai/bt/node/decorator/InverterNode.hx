package dropecho.ai.bt.node.decorator;

/**
 * An Inverter: swaps the child's SUCCESS and FAILURE.
 */
@:expose("bt.InverterNode")
class InverterNode extends DecoratorNode {
	/**
	 * Creates an Inverter.
	 *
	 * @param child - The node whose Status is inverted.
	 */
	public function new(child:Node) {
		super(child);
	}

	/**
	 * Runs the child once.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return FAILURE if the child succeeded, SUCCESS if it failed, RUNNING if it is still running.
	 */
	public function execute(deltaTime:Float):NODE_STATUS {
		var status = executeChild(deltaTime);

		switch (status) {
			case NODE_STATUS.SUCCESS:
				return NODE_STATUS.FAILURE;

			case NODE_STATUS.FAILURE:
				return NODE_STATUS.SUCCESS;

			case NODE_STATUS.RUNNING:
				return NODE_STATUS.RUNNING;
		}
	}
}
