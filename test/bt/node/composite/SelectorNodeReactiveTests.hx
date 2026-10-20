package bt.node.composite;

import utest.Test;
import utest.Assert;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.Blackboard;
import bt.node.TestNode;
import dropecho.ai.bt.node.composite.SelectorNode;

class SelectorNodeReactiveTests extends Test {
	private var highPriorityNode:TestNode;
	private var lowPriorityNode:TestNode;
	private var node:SelectorNode;

	public function setup() {
		this.highPriorityNode = new TestNode(NODE_STATUS.FAILURE);
		this.lowPriorityNode = new TestNode();

		var children = new Array<Node>();
		children.push(highPriorityNode);
		children.push(lowPriorityNode);

		this.node = new SelectorNode(children, true);
		this.node.init(new Blackboard());
	}

	public function test_when_the_first_child_fails_it_should_run_the_second_child_in_the_same_tick() {
		var status = this.node.execute(0);

		Assert.equals(NODE_STATUS.SUCCESS, status);
		Assert.equals(1, highPriorityNode.executed);
		Assert.equals(1, lowPriorityNode.executed);
	}

	public function test_when_a_child_is_running_it_should_recheck_earlier_children_each_tick() {
		lowPriorityNode.execReturn = NODE_STATUS.RUNNING;

		Assert.equals(NODE_STATUS.RUNNING, this.node.execute(0));
		Assert.equals(NODE_STATUS.RUNNING, this.node.execute(0));

		Assert.equals(2, highPriorityNode.executed);
		Assert.equals(2, lowPriorityNode.executed);
	}

	public function test_when_a_higher_priority_child_starts_succeeding_it_should_switch_to_it_and_stop_ticking_the_running_child() {
		lowPriorityNode.execReturn = NODE_STATUS.RUNNING;
		this.node.execute(0);

		highPriorityNode.execReturn = NODE_STATUS.SUCCESS;

		Assert.equals(NODE_STATUS.SUCCESS, this.node.execute(0));
		Assert.equals(NODE_STATUS.SUCCESS, this.node.execute(0));
		Assert.equals(3, highPriorityNode.executed);
		Assert.equals(1, lowPriorityNode.executed);
	}

	public function test_when_every_child_fails_it_should_fail_and_start_from_the_first_child_next_tick() {
		lowPriorityNode.execReturn = NODE_STATUS.FAILURE;

		Assert.equals(NODE_STATUS.FAILURE, this.node.execute(0));
		Assert.equals(NODE_STATUS.FAILURE, this.node.execute(0));

		Assert.equals(2, highPriorityNode.executed);
		Assert.equals(2, lowPriorityNode.executed);
	}

	public function test_it_should_init_children_with_context() {
		Assert.notNull(highPriorityNode.context);
		Assert.notNull(lowPriorityNode.context);
	}

	public function test_reactive_defaults_to_false() {
		var plain = new SelectorNode([new TestNode()]);
		Assert.isFalse(plain.reactive);
	}

	public function test_turning_reactive_off_resumes_the_running_child() {
		lowPriorityNode.execReturn = NODE_STATUS.RUNNING;
		this.node.execute(0);
		this.node.reactive = false;

		this.node.execute(0);

		Assert.equals(1, highPriorityNode.executed);
		Assert.equals(2, lowPriorityNode.executed);
	}
}
