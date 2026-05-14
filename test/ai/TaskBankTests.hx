package ai;

import utest.Test;
import utest.Assert;
import dropecho.ai.TaskBank;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.NODE_STATUS;

class TaskBankTests extends Test {
	public function setup() {
		TaskBank.register("test_task", function(bb:Blackboard):NODE_STATUS {
			return NODE_STATUS.SUCCESS;
		});
	}

	public function test_register_and_get_returns_the_registered_task() {
		TaskBank.register("test_task", function(bb:Blackboard):NODE_STATUS {
			return NODE_STATUS.SUCCESS;
		});
		var task = TaskBank.get("test_task");
		Assert.notNull(task);
	}

	public function test_registered_task_is_callable() {
		TaskBank.register("test_task", function(bb:Blackboard):NODE_STATUS {
			return NODE_STATUS.SUCCESS;
		});
		var task = TaskBank.get("test_task");
		var bb = new Blackboard();
		var result = task(bb);
		Assert.equals(NODE_STATUS.SUCCESS, result);
	}
}
