package bt.node.decorator;

import utest.Test;
import utest.Assert;
import dropecho.ai.bt.node.NODE_STATUS;
import bt.node.TestNode;
import dropecho.ai.bt.node.decorator.InverterNode;

class InverterNodeTests extends Test {
	public function test_when_execute_is_called_on_a_failing_node_it_should_return_success() {
		var node = new InverterNode(new TestNode(NODE_STATUS.FAILURE));
		var status = node.execute();
		Assert.equals(NODE_STATUS.SUCCESS, status);
	}

	public function test_when_execute_is_called_on_a_succes_node_it_should_return_failure() {
		var node = new InverterNode(new TestNode(NODE_STATUS.SUCCESS));
		var status = node.execute();
		Assert.equals(NODE_STATUS.FAILURE, status);
	}

	public function test_on_running_it_should_return_running() {
		var node = new InverterNode(new TestNode(NODE_STATUS.RUNNING));
		var status = node.execute();
		Assert.equals(NODE_STATUS.RUNNING, status);
	}
}
