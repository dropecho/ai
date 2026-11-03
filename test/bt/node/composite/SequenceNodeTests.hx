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

		Assert.equals(NODE_STATUS.FAILURE, this.node.execute(0));
		Assert.equals(NODE_STATUS.FAILURE, this.node.execute(0));

		Assert.equals(0, testNode.executed);
	}

	public function test_when_all_children_succeed_it_should_succeed_on_the_first_execute_and_run_every_child() {
		var tn2 = new TestNode();
		children.unshift(tn2);

		var status = this.node.execute(0);

		Assert.equals(NODE_STATUS.SUCCESS, status);
		Assert.equals(1, tn2.executed);
		Assert.equals(1, testNode.executed);
	}

	public function test_when_the_last_child_succeeds_it_should_start_from_the_first_child_next_tick() {
		var tn2 = new TestNode();
		children.unshift(tn2);

		this.node.execute(0);
		this.node.execute(0);
		this.node.execute(0);

		Assert.equals(3, tn2.executed);
		Assert.equals(3, testNode.executed);
	}

	public function test_when_a_later_child_fails_it_should_fail_in_the_same_tick_and_reset() {
		var tn2 = new TestNode();
		children.unshift(tn2);
		testNode.execReturn = NODE_STATUS.FAILURE;

		Assert.equals(NODE_STATUS.FAILURE, this.node.execute(0));
		Assert.equals(NODE_STATUS.FAILURE, this.node.execute(0));

		Assert.equals(2, tn2.executed);
		Assert.equals(2, testNode.executed);
	}

	public function test_when_a_child_is_running_it_should_resume_that_child_next_tick_without_rerunning_earlier_children() {
		var tn2 = new TestNode();
		children.unshift(tn2);
		testNode.execReturn = NODE_STATUS.RUNNING;

		Assert.equals(NODE_STATUS.RUNNING, this.node.execute(0));
		Assert.equals(NODE_STATUS.RUNNING, this.node.execute(0));

		Assert.equals(1, tn2.executed);
		Assert.equals(2, testNode.executed);

		testNode.execReturn = NODE_STATUS.SUCCESS;

		Assert.equals(NODE_STATUS.SUCCESS, this.node.execute(0));
		Assert.equals(1, tn2.executed);
		Assert.equals(3, testNode.executed);
	}

	public function test_tree_should_init_root_node_with_context() {
		Assert.notNull(testNode.context);
	}
}
