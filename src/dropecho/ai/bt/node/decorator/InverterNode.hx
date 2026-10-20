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
	 * @return FAILURE if the child succeeded, SUCCESS if it failed, RUNNING if it is still running.
	 */
	public function execute():NODE_STATUS {
		var status = this.child.execute();

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
