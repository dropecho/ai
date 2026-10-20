package bt.node.composite;

import utest.Test;
import utest.Assert;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.Blackboard;
import bt.node.TestNode;
import dropecho.ai.bt.node.composite.SequenceNode;

class SequenceNodeReactiveTests extends Test {
	private var conditionNode:TestNode;
	private var actionNode:TestNode;
	private var node:SequenceNode;

	public function setup() {
		this.conditionNode = new TestNode(NODE_STATUS.SUCCESS);
		this.actionNode = new TestNode();

		var children = new Array<Node>();
		children.push(conditionNode);
		children.push(actionNode);

		this.node = new SequenceNode(children, true);
		this.node.init(new Blackboard());
	}

	public function test_when_the_first_child_succeeds_it_should_run_the_second_child_in_the_same_tick() {
		var status = this.node.execute(0);

		Assert.equals(NODE_STATUS.SUCCESS, status);
		Assert.equals(1, conditionNode.executed);
		Assert.equals(1, actionNode.executed);
	}

	public function test_when_a_child_is_running_it_should_recheck_the_earlier_condition_each_tick() {
		actionNode.execReturn = NODE_STATUS.RUNNING;

		Assert.equals(NODE_STATUS.RUNNING, this.node.execute(0));
		Assert.equals(NODE_STATUS.RUNNING, this.node.execute(0));

		Assert.equals(2, conditionNode.executed);
		Assert.equals(2, actionNode.executed);
	}

	public function test_when_the_earlier_condition_stops_holding_it_should_fail_without_ticking_the_running_child() {
		actionNode.execReturn = NODE_STATUS.RUNNING;
		this.node.execute(0);

		conditionNode.execReturn = NODE_STATUS.FAILURE;

		Assert.equals(NODE_STATUS.FAILURE, this.node.execute(0));
		Assert.equals(2, conditionNode.executed);
		Assert.equals(1, actionNode.executed);
	}

	public function test_when_it_succeeds_it_should_start_from_the_first_child_next_tick() {
		Assert.equals(NODE_STATUS.SUCCESS, this.node.execute(0));
		Assert.equals(NODE_STATUS.SUCCESS, this.node.execute(0));

		Assert.equals(2, conditionNode.executed);
		Assert.equals(2, actionNode.executed);
	}

	public function test_it_should_init_children_with_context() {
		Assert.notNull(conditionNode.context);
		Assert.notNull(actionNode.context);
	}
}
