package dropecho.ai.bt.node;

import dropecho.ai.Blackboard;
import dropecho.util.NotImplementedException;

@:expose("bt.LeafNode")
class LeafNode implements Node {
	private var context:Blackboard;

	public function new() {}

	public function init(context:Blackboard):Void {
		this.context = context;
	}

	public function execute():NODE_STATUS {
		throw new NotImplementedException();
	}
}
