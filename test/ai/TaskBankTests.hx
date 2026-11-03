package ai;

import utest.Test;
import utest.Assert;
import dropecho.ai.TaskBank;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.NODE_STATUS;

class TaskBankTests extends Test {
	public function setup() {
		TaskBank.register("test_task", function(bb:Blackboard, deltaTime:Float):NODE_STATUS {
			return NODE_STATUS.SUCCESS;
		});
	}

	public function test_register_and_get_returns_the_registered_task() {
		TaskBank.register("test_task", function(bb:Blackboard, deltaTime:Float):NODE_STATUS {
			return NODE_STATUS.SUCCESS;
		});
		var task = TaskBank.get("test_task");
		Assert.notNull(task);
	}

	public function test_registered_task_is_callable() {
		TaskBank.register("test_task", function(bb:Blackboard, deltaTime:Float):NODE_STATUS {
			return NODE_STATUS.SUCCESS;
		});
		var task = TaskBank.get("test_task");
		var bb = new Blackboard();
		var result = task(bb, 0);
		Assert.equals(NODE_STATUS.SUCCESS, result);
	}

	public function test_get_of_an_unknown_task_throws_naming_it_and_how_to_register_it() {
		var message = "";
		try {
			TaskBank.get("unregistered_task");
		} catch (e) {
			message = e.message;
		}

		Assert.stringContains('Unknown task "unregistered_task"', message);
		Assert.stringContains("Registered tasks: ", message);
		Assert.stringContains("test_task", message);
		Assert.stringContains('TaskBank.register("unregistered_task", (context, deltaTime) -> NODE_STATUS.SUCCESS)', message);
	}
}
