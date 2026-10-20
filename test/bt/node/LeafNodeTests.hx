package bt.node;

import utest.Test;
import utest.Assert;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.LeafNode;
import dropecho.ai.bt.node.NODE_STATUS;

private class HasContextLeaf extends LeafNode {
	public function new() {
		super();
	}

	public function execute():NODE_STATUS {
		var hasContext = context != null;
		return hasContext ? NODE_STATUS.SUCCESS : NODE_STATUS.FAILURE;
	}
}

class LeafNodeTests extends Test {
	public function test_subclass_execute_should_run_without_override() {
		var leaf = new HasContextLeaf();
		leaf.init(new Blackboard());

		Assert.equals(NODE_STATUS.SUCCESS, leaf.execute());
	}

	public function test_execute_should_have_no_context_before_init() {
		var leaf = new HasContextLeaf();

		Assert.equals(NODE_STATUS.FAILURE, leaf.execute());
	}
}
