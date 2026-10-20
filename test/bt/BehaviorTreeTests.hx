package bt;

import dropecho.ai.Blackboard;
import utest.Test;
import utest.Assert;
import dropecho.ai.bt.BehaviorTree;
import bt.node.TestNode;

class BehaviorTreeTests extends Test {
	private var testNode:TestNode;
	private var tree:BehaviorTree;

	public function setup() {
		this.testNode = new TestNode();
		this.tree = new BehaviorTree(this.testNode);
		this.tree.init(new Blackboard());
	}

	public function test_when_execute_is_called_on_the_tree_it_should_execute_the_root_node() {
		this.tree.execute(0);

		Assert.equals(1, testNode.executed);
	}

	public function test_tree_should_init_root_node_with_context() {
		Assert.notNull(testNode.context);
	}

	public function test_new_should_throw_a_message_naming_the_fix_when_root_is_null() {
		var message = "";
		try {
			new BehaviorTree(null);
		} catch (e:String) {
			message = e;
		}

		Assert.stringContains("new BehaviorTree(new SequenceNode(", message);
	}
}
