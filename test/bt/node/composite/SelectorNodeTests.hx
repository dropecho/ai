package bt.node.composite;

import utest.Test;
import utest.Assert;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.Blackboard;
import bt.node.TestNode;
import dropecho.ai.bt.node.composite.SelectorNode;

class SelectorNodeTests extends Test {
	private var failingNode:TestNode;
	private var testNode:TestNode;
	private var node:SelectorNode;

	public function setup() {
		this.failingNode = new TestNode(NODE_STATUS.FAILURE);
		this.testNode = new TestNode();

		var children = new Array<Node>();
		children.push(failingNode);
		children.push(testNode);

		this.node = new SelectorNode(children);
		this.node.init(new Blackboard());
	}

	public function test_when_the_first_child_fails_it_should_run_the_second_child_in_the_same_tick() {
		var status = this.node.execute();

		Assert.equals(NODE_STATUS.SUCCESS, status);
		Assert.equals(1, failingNode.executed);
		Assert.equals(1, testNode.executed);
	}

	public function test_when_a_child_succeeds_it_should_start_from_the_first_child_next_tick() {
		this.node.execute();
		this.node.execute();

		Assert.equals(2, failingNode.executed);
		Assert.equals(2, testNode.executed);
	}

	public function test_when_the_first_child_succeeds_it_should_not_run_the_rest() {
		failingNode.execReturn = NODE_STATUS.SUCCESS;

		var status = this.node.execute();

		Assert.equals(NODE_STATUS.SUCCESS, status);
		Assert.equals(0, testNode.executed);
	}

	public function test_when_every_child_fails_it_should_fail_in_one_tick_and_reset() {
		testNode.execReturn = NODE_STATUS.FAILURE;

		Assert.equals(NODE_STATUS.FAILURE, this.node.execute());
		Assert.equals(NODE_STATUS.FAILURE, this.node.execute());

		Assert.equals(2, failingNode.executed);
		Assert.equals(2, testNode.executed);
	}

	public function test_when_a_child_is_running_it_should_resume_that_child_next_tick_without_rerunning_earlier_children() {
		testNode.execReturn = NODE_STATUS.RUNNING;

		Assert.equals(NODE_STATUS.RUNNING, this.node.execute());
		Assert.equals(NODE_STATUS.RUNNING, this.node.execute());

		Assert.equals(1, failingNode.executed);
		Assert.equals(2, testNode.executed);

		testNode.execReturn = NODE_STATUS.SUCCESS;

		Assert.equals(NODE_STATUS.SUCCESS, this.node.execute());
		Assert.equals(1, failingNode.executed);
		Assert.equals(3, testNode.executed);
	}

	public function test_tree_should_init_root_node_with_context() {
		Assert.notNull(testNode.context);
	}
}
