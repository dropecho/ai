package bt.node.decorator;

import utest.Test;
import utest.Assert;
import dropecho.ai.bt.node.NODE_STATUS;
import bt.node.TestNode;
import dropecho.ai.bt.node.decorator.ForceFailureNode;

class ForceFailureNodeTests extends Test {
	public function test_a_succeeding_child_gives_failure() {
		var node = new ForceFailureNode(new TestNode(NODE_STATUS.SUCCESS));
		Assert.equals(NODE_STATUS.FAILURE, node.execute(0));
	}

	public function test_a_failing_child_gives_failure() {
		var node = new ForceFailureNode(new TestNode(NODE_STATUS.FAILURE));
		Assert.equals(NODE_STATUS.FAILURE, node.execute(0));
	}

	public function test_a_running_child_gives_running() {
		var node = new ForceFailureNode(new TestNode(NODE_STATUS.RUNNING));
		Assert.equals(NODE_STATUS.RUNNING, node.execute(0));
	}

	public function test_halting_halts_the_child() {
		var child = new TestNode(NODE_STATUS.RUNNING);
		var node = new ForceFailureNode(child);
		node.execute(0);
		node.halt();
		Assert.equals(1, child.halted);
	}
}
