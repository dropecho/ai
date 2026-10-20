package bt.node.decorator;

import utest.Test;
import utest.Assert;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;
import bt.node.TestNode;
import dropecho.ai.bt.node.decorator.RetryNode;

class RetryNodeTests extends Test {
	public function test_a_child_success_succeeds_at_once() {
		var child = new TestNode(NODE_STATUS.SUCCESS);
		var node = new RetryNode(child, 3);

		var status = node.execute(0);

		Assert.equals(NODE_STATUS.SUCCESS, status);
		Assert.equals(1, child.executed);
	}

	public function test_a_failing_instant_child_is_retried_within_one_tick_until_attempts_run_out() {
		var child = new TestNode(NODE_STATUS.FAILURE);
		var node = new RetryNode(child, 3);

		var status = node.execute(0);

		Assert.equals(NODE_STATUS.FAILURE, status);
		Assert.equals(3, child.executed);
	}

	public function test_a_child_that_succeeds_on_a_later_attempt_succeeds() {
		var child = new ScriptedNode([NODE_STATUS.FAILURE, NODE_STATUS.FAILURE, NODE_STATUS.SUCCESS]);
		var node = new RetryNode(child, 3);

		var status = node.execute(0);

		Assert.equals(NODE_STATUS.SUCCESS, status);
		Assert.equals(3, child.executed);
	}

	public function test_a_running_child_returns_running_and_is_resumed_keeping_the_attempts() {
		var child = new ScriptedNode([NODE_STATUS.FAILURE, NODE_STATUS.RUNNING, NODE_STATUS.FAILURE, NODE_STATUS.SUCCESS]);
		var node = new RetryNode(child, 2);

		var first = node.execute(0);
		var second = node.execute(0);

		Assert.equals(NODE_STATUS.RUNNING, first);
		Assert.equals(NODE_STATUS.FAILURE, second);
		Assert.equals(3, child.executed);
	}

	public function test_it_has_every_attempt_again_after_finishing() {
		var child = new TestNode(NODE_STATUS.FAILURE);
		var node = new RetryNode(child, 2);

		node.execute(0);
		var status = node.execute(0);

		Assert.equals(NODE_STATUS.FAILURE, status);
		Assert.equals(4, child.executed);
	}

	public function test_halting_halts_the_running_child_and_resets_the_attempts() {
		var child = new ScriptedNode([NODE_STATUS.FAILURE, NODE_STATUS.RUNNING, NODE_STATUS.FAILURE, NODE_STATUS.SUCCESS]);
		var node = new RetryNode(child, 2);
		node.init(new Blackboard());

		node.execute(0);
		node.halt();
		var status = node.execute(0);

		Assert.equals(1, child.halted);
		Assert.equals(NODE_STATUS.SUCCESS, status);
		Assert.equals(4, child.executed);
	}

	public function test_attempts_below_one_throw_a_message_with_an_example() {
		var message = "";
		try {
			new RetryNode(new TestNode(), 0);
		} catch (error:String) {
			message = error;
		}

		Assert.stringContains("got 0", message);
		Assert.stringContains("new RetryNode(child, 3)", message);
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
