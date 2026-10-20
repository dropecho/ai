package dropecho.ai.bt.node.decorator;

abstract class DecoratorNode implements Node {
	private var child:Node;
	private var context:Blackboard;

	public function new(child:Node) {
		this.child = child;
	}

	public function init(context:Blackboard):Void {
		this.context = context;
		if (this.child.init != null) {
			this.child.init(context);
		}
	}

	abstract public function execute():NODE_STATUS;
}
