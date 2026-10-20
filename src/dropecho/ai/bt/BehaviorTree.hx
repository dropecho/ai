package dropecho.ai.bt;

import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;

@:expose("bt.BehaviorTree")
class BehaviorTree implements Node {
	private var child:Node;
	private var context:Blackboard;

	public function new(root:Node = null) {
		if (root == null) {
			throw "Root cannot be null";
		}

		this.child = root;
	}

	public function init(context:Blackboard):Void {
		if (context == null) {
			context = new Blackboard();
		}

		this.context = context;
		child.init(this.context);
	}

	public function execute():NODE_STATUS {
		return this.child.execute();
	}
}
