package bt.node;

import utest.Test;
import utest.Assert;
import dropecho.ai.TaskBank;
import dropecho.ai.bt.node.TaskNode;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.NODE_STATUS;

class TaskNodeTests extends Test {
	public function setup() {
		TaskBank.register("task_node_test", function(bb:Blackboard):NODE_STATUS {
			return NODE_STATUS.SUCCESS;
		});
	}

	public function test_execute_calls_the_registered_task() {
		var node = new TaskNode("task_node_test");
		var bb = new Blackboard();
		node.init(bb);
		var result = node.execute();
		Assert.equals(NODE_STATUS.SUCCESS, result);
	}

	public function test_init_provides_context_to_task() {
		var contextWasNotNull = false;
		TaskBank.register("task_node_context_test", function(bb:Blackboard):NODE_STATUS {
			contextWasNotNull = (bb != null);
			return NODE_STATUS.SUCCESS;
		});
		var node = new TaskNode("task_node_context_test");
		var bb = new Blackboard();
		node.init(bb);
		node.execute();
		Assert.isTrue(contextWasNotNull);
	}
}
