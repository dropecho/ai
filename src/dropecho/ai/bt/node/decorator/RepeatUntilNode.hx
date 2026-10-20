package dropecho.ai.bt.node.decorator;

@:expose("bt.RepeatUntilNode")
class RepeatUntilNode extends DecoratorNode {
	public function new(child:Node) {
		super(child);
	}

	public function execute():NODE_STATUS {
		var status = child.execute();

		var keepRepeating = status == NODE_STATUS.SUCCESS || status == NODE_STATUS.RUNNING;
		if (keepRepeating) {
			return NODE_STATUS.RUNNING;
		}

		return NODE_STATUS.SUCCESS;
	}
}
