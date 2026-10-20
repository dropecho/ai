package dropecho.ai.bt.node.composite;

using Lambda;

import dropecho.util.CurrentIterator;

abstract class CompositeNode implements Node {
	private var children:Array<Node>;
	private var childIterator:CurrentIterator<Node>;
	private var context:Blackboard;

	public function new(children:Array<Node>) {
		this.children = children;
		this.childIterator = new CurrentIterator(children);
	}

	public function init(context:Blackboard):Void {
		this.context = context;

		function initChild(child) {
			if (child.init != null) {
				child.init(context);
			}
		}

		this.children.iter(initChild);
	}

	abstract public function execute():NODE_STATUS;
}
