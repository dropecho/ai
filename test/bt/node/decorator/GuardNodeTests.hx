package bt.node.decorator;

import utest.Test;
import utest.Assert;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.bt.node.decorator.GuardNode;
import bt.node.TestNode;

class GuardNodeTests extends Test {
	private var isAllowed:Bool;
	private var child:TestNode;
	private var guard:GuardNode;

	public function setup() {
		isAllowed = true;
		child = new TestNode(NODE_STATUS.RUNNING);
		guard = new GuardNode(context -> isAllowed, child);
		guard.init(new Blackboard());
	}

	public function test_a_false_check_fails_without_running_the_child() {
		isAllowed = false;

		var status = guard.execute(0);

		Assert.equals(NODE_STATUS.FAILURE, status);
		Assert.equals(0, child.executed);
	}

	public function test_a_true_check_returns_the_child_status() {
		Assert.equals(NODE_STATUS.RUNNING, guard.execute(0));

		child.execReturn = NODE_STATUS.SUCCESS;
		Assert.equals(NODE_STATUS.SUCCESS, guard.execute(0));

		child.execReturn = NODE_STATUS.FAILURE;
		Assert.equals(NODE_STATUS.FAILURE, guard.execute(0));
	}

	public function test_the_child_gets_the_delta_time() {
		guard.execute(0.5);

		Assert.equals(0.5, child.lastDeltaTime);
	}

	public function test_a_check_turning_false_while_the_child_runs_halts_it_and_fails() {
		guard.execute(0);
		isAllowed = false;
		var status = guard.execute(0);

		Assert.equals(NODE_STATUS.FAILURE, status);
		Assert.equals(1, child.halted);
		Assert.equals(1, child.executed);
	}

	public function test_a_false_check_does_not_halt_a_child_that_is_not_running() {
		child.execReturn = NODE_STATUS.SUCCESS;
		guard.execute(0);
		isAllowed = false;
		guard.execute(0);

		Assert.equals(0, child.halted);
	}

	public function test_halting_the_guard_halts_its_running_child_once() {
		guard.execute(0);
		guard.halt();
		guard.halt();

		Assert.equals(1, child.halted);
	}
}
