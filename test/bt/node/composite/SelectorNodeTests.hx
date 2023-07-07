package bt.node.composite;

import utest.Test;
import utest.Assert;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.Blackboard;
import bt.node.TestNode;
import dropecho.ai.bt.node.composite.SelectorNode;

class SelectorNodeTests extends Test {
	private var testNode:TestNode;
	private var node:SelectorNode;

	public function setup() {
		this.testNode = new TestNode();

		var children = new Array<Node>();
		children.push(new TestNode(NODE_STATUS.FAILURE));
		children.push(testNode);

		this.node = new SelectorNode(children);
		this.node.init(new Blackboard());
	}

	public function test_when_execute_is_called_it_should_execute_the_children() {
		// execute, and fail first.
		this.node.execute();

		// second execution should run the this.testNode;
		this.node.execute();

		Assert.equals(1, testNode.executed);
	}

	public function test_when_execute_is_called_and_we_hit_the_end_of_the_list_it_should_reset() {
		// execute, and fail first.
		this.node.execute();

		// second execution should run the this.testNode;
		this.node.execute();

		// this third call should execute the first node again, since it should have reset the internal counter.
		this.node.execute();
		this.node.execute();

		Assert.equals(2, testNode.executed);
	}

	public function test_tree_should_init_root_node_with_context() {
		Assert.notNull(testNode.context);
	}
}
