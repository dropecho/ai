package bt.node.decorator;

import utest.Test;
import utest.Assert;
import dropecho.ai.bt.node.NODE_STATUS;
import bt.node.TestNode;
import dropecho.ai.bt.node.decorator.RepeaterNode;

class RepeaterNodeTests extends Test {
	public function test_when_execute_is_called_and_the_child_node_is_failing_it_should_return_running() {
		var node = new RepeaterNode(new TestNode(NODE_STATUS.FAILURE));
		var status = node.execute();
		Assert.equals(NODE_STATUS.RUNNING, status);
	}

	public function test_when_execute_is_called_and_the_child_node_is_successful_it_should_return_running() {
		var node = new RepeaterNode(new TestNode(NODE_STATUS.SUCCESS));
		var status = node.execute();
		Assert.equals(NODE_STATUS.RUNNING, status);
	}

	public function test_when_execute_is_called_and_the_child_node_is_running_it_should_return_running() {
		var node = new RepeaterNode(new TestNode(NODE_STATUS.RUNNING));
		var status = node.execute();
		Assert.equals(NODE_STATUS.RUNNING, status);
	}
}
