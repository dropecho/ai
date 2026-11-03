package bt.node.decorator;

import utest.Test;
import utest.Assert;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;
import bt.node.TestNode;
import dropecho.ai.bt.node.decorator.RepeaterNode;

class RepeaterNodeTests extends Test {
	public function test_when_execute_is_called_and_the_child_node_is_failing_it_should_return_running() {
		var node = new RepeaterNode(new TestNode(NODE_STATUS.FAILURE));
		var status = node.execute(0);
		Assert.equals(NODE_STATUS.RUNNING, status);
	}

	public function test_when_execute_is_called_and_the_child_node_is_successful_it_should_return_running() {
		var node = new RepeaterNode(new TestNode(NODE_STATUS.SUCCESS));
		var status = node.execute(0);
		Assert.equals(NODE_STATUS.RUNNING, status);
	}

	public function test_when_execute_is_called_and_the_child_node_is_running_it_should_return_running() {
		var node = new RepeaterNode(new TestNode(NODE_STATUS.RUNNING));
		var status = node.execute(0);
		Assert.equals(NODE_STATUS.RUNNING, status);
	}

	public function test_without_a_count_it_runs_the_child_once_per_tick() {
		var child = new TestNode(NODE_STATUS.SUCCESS);
		var node = new RepeaterNode(child);

		node.execute(0);
		node.execute(0);

		Assert.equals(2, child.executed);
	}

	public function test_without_a_count_halting_halts_a_running_child() {
		var child = new TestNode(NODE_STATUS.RUNNING);
		var node = new RepeaterNode(child);

		node.execute(0);
		node.halt();

		Assert.equals(1, child.halted);
	}

	public function test_without_a_count_halting_does_not_halt_a_finished_child() {
		var child = new TestNode(NODE_STATUS.SUCCESS);
		var node = new RepeaterNode(child);

		node.execute(0);
		node.halt();

		Assert.equals(0, child.halted);
	}

	public function test_with_a_count_an_instant_child_is_repeated_within_one_tick() {
		var child = new TestNode(NODE_STATUS.SUCCESS);
		var node = new RepeaterNode(child, 3);

		var status = node.execute(0);

		Assert.equals(NODE_STATUS.SUCCESS, status);
		Assert.equals(3, child.executed);
	}

	public function test_with_a_count_a_child_failure_fails_the_repeater() {
		var child = new ScriptedNode([NODE_STATUS.SUCCESS, NODE_STATUS.FAILURE]);
		var node = new RepeaterNode(child, 3);

		var status = node.execute(0);

		Assert.equals(NODE_STATUS.FAILURE, status);
		Assert.equals(2, child.executed);
	}

	public function test_with_a_count_a_running_child_is_resumed_keeping_the_count() {
		var child = new ScriptedNode([NODE_STATUS.SUCCESS, NODE_STATUS.RUNNING, NODE_STATUS.SUCCESS]);
		var node = new RepeaterNode(child, 2);

		var first = node.execute(0);
		var second = node.execute(0);

		Assert.equals(NODE_STATUS.RUNNING, first);
		Assert.equals(NODE_STATUS.SUCCESS, second);
		Assert.equals(3, child.executed);
	}

	public function test_with_a_count_it_starts_counting_again_after_finishing() {
		var child = new TestNode(NODE_STATUS.SUCCESS);
		var node = new RepeaterNode(child, 2);

		node.execute(0);
		var status = node.execute(0);

		Assert.equals(NODE_STATUS.SUCCESS, status);
		Assert.equals(4, child.executed);
	}

	public function test_with_a_count_it_starts_counting_again_after_failing() {
		var child = new ScriptedNode([NODE_STATUS.SUCCESS, NODE_STATUS.FAILURE, NODE_STATUS.SUCCESS, NODE_STATUS.SUCCESS]);
		var node = new RepeaterNode(child, 2);

		node.execute(0);
		var status = node.execute(0);

		Assert.equals(NODE_STATUS.SUCCESS, status);
		Assert.equals(4, child.executed);
	}

	public function test_with_a_count_halting_halts_the_running_child_and_resets_the_count() {
		var child = new ScriptedNode([NODE_STATUS.SUCCESS, NODE_STATUS.RUNNING, NODE_STATUS.SUCCESS, NODE_STATUS.SUCCESS]);
		var node = new RepeaterNode(child, 2);
		node.init(new Blackboard());

		node.execute(0);
		node.halt();
		var status = node.execute(0);

		Assert.equals(1, child.halted);
		Assert.equals(NODE_STATUS.SUCCESS, status);
		Assert.equals(4, child.executed);
	}

	public function test_a_count_below_one_throws_a_message_with_an_example() {
		var message = "";
		try {
			new RepeaterNode(new TestNode(), 0);
		} catch (error:String) {
			message = error;
		}

		Assert.stringContains("got 0", message);
		Assert.stringContains("new RepeaterNode(child, 3)", message);
	}
}

private class ScriptedNode implements Node {
	public var executed:Int = 0;
	public var halted:Int = 0;

	private var statuses:Array<NODE_STATUS>;

	public function new(statuses:Array<NODE_STATUS>) {
		this.statuses = statuses;
	}

	public function init(context:Blackboard):Void {}

	public function execute(deltaTime:Float):NODE_STATUS {
		var isPastTheScript = executed >= statuses.length;
		var status = isPastTheScript ? statuses[statuses.length - 1] : statuses[executed];
		executed++;
		return status;
	}

	public function halt():Void {
		halted++;
	}
}
