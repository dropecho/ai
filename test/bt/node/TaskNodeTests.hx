package bt.node;

import utest.Test;
import utest.Assert;
import dropecho.ai.TaskBank;
import dropecho.ai.bt.node.TaskNode;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.NODE_STATUS;

class TaskNodeTests extends Test {
	public function setup() {
		TaskBank.register("task_node_test", function(bb:Blackboard, deltaTime:Float):NODE_STATUS {
			return NODE_STATUS.SUCCESS;
		});
	}

	public function test_execute_calls_the_registered_task() {
		var node = new TaskNode("task_node_test");
		var bb = new Blackboard();
		node.init(bb);
		var result = node.execute(0);
		Assert.equals(NODE_STATUS.SUCCESS, result);
	}

	public function test_init_provides_context_to_task() {
		var contextWasNotNull = false;
		TaskBank.register("task_node_context_test", function(bb:Blackboard, deltaTime:Float):NODE_STATUS {
			contextWasNotNull = (bb != null);
			return NODE_STATUS.SUCCESS;
		});
		var node = new TaskNode("task_node_context_test");
		var bb = new Blackboard();
		node.init(bb);
		node.execute(0);
		Assert.isTrue(contextWasNotNull);
	}

	public function test_new_with_an_unknown_task_name_throws() {
		Assert.raises(() -> new TaskNode("unregistered_task_node"));
	}

	public function test_a_task_given_directly_runs_without_the_registry() {
		var node = new TaskNode("not_registered", (bb, deltaTime) -> NODE_STATUS.FAILURE);
		node.init(new Blackboard());
		Assert.equals(NODE_STATUS.FAILURE, node.execute(0));
	}

	public function test_a_task_given_directly_wins_over_a_registered_one_of_the_same_name() {
		var node = new TaskNode("task_node_test", (bb, deltaTime) -> NODE_STATUS.RUNNING);
		node.init(new Blackboard());
		Assert.equals(NODE_STATUS.RUNNING, node.execute(0));
	}

	public function test_a_task_given_directly_gets_the_blackboard_and_delta_time() {
		var bb = new Blackboard();
		var seenContext:Blackboard = null;
		var seenDeltaTime = 0.0;
		var node = new TaskNode("direct", (context, deltaTime) -> {
			seenContext = context;
			seenDeltaTime = deltaTime;
			return NODE_STATUS.SUCCESS;
		});
		node.init(bb);
		node.execute(0.5);
		Assert.equals(bb, seenContext);
		Assert.equals(0.5, seenDeltaTime);
	}

	public function test_a_task_given_directly_is_labelled_with_its_name() {
		var node = new TaskNode("eat", (bb, deltaTime) -> NODE_STATUS.SUCCESS);
		Assert.equals("eat", node.getLabel());
	}

	public function test_a_task_given_directly_may_have_no_name() {
		var node = new TaskNode(null, (bb, deltaTime) -> NODE_STATUS.SUCCESS);
		Assert.isNull(node.getLabel());
	}
}
