package bt.node.composite;

import utest.Test;
import utest.Assert;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.composite.SequenceNode;

class SequenceNodeTests extends Test {
	private var testNode:TestNode;
	private var node:SequenceNode;
	private var children:Array<Node>;

	public function setup() {
		this.testNode = new TestNode();

		children = new Array<Node>();
		children.push(testNode);

		this.node = new SequenceNode(children);
		this.node.init(new Blackboard());
	}

	public function test_when_execute_is_called_and_the_first_node_fails_it_should_not_call_the_second_node() {
		children.unshift(new TestNode(NODE_STATUS.FAILURE));

		// execute, and fail first.
		this.node.execute();

		// because the first fails, the sequence fails, so we should never call the test node
		this.node.execute();

		Assert.equals(0, testNode.executed);
	}

	public function test_when_execute_is_called_and_all_children_return_success_all_children_should_be_called() {
		var tn2 = new TestNode();
		children.unshift(tn2);

		this.node.execute();
		this.node.execute();

		Assert.equals(1, tn2.executed);
		Assert.equals(1, testNode.executed);
	}

	public function test_when_execute_is_called_and_the_end_of_the_list_of_children_is_reached_it_should_reset_the_child_list() {
		var tn2 = new TestNode();
		children.unshift(tn2);

		this.node.execute();
		this.node.execute();

		this.node.execute();
		this.node.execute();

		this.node.execute();
		this.node.execute();

		Assert.equals(3, tn2.executed);
		Assert.equals(3, testNode.executed);
	}

	public function test_tree_should_init_root_node_with_context() {
		Assert.notNull(testNode.context);
	}
}
