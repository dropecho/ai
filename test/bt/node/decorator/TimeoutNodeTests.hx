package bt.node.decorator;

import utest.Test;
import utest.Assert;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.bt.node.WaitNode;
import bt.node.TestNode;
import dropecho.ai.bt.node.decorator.TimeoutNode;

class TimeoutNodeTests extends Test {
	public function test_timeout_passes_through_the_childs_status_within_the_limit() {
		var child = new TestNode(NODE_STATUS.RUNNING);
		var timeout = new TimeoutNode(child, 1);

		Assert.equals(NODE_STATUS.RUNNING, timeout.execute(0));
		child.execReturn = NODE_STATUS.SUCCESS;
		Assert.equals(NODE_STATUS.SUCCESS, timeout.execute(0.5));

		child.execReturn = NODE_STATUS.FAILURE;
		Assert.equals(NODE_STATUS.FAILURE, timeout.execute(0.5));
	}

	public function test_timeout_fails_and_halts_the_child_once_the_limit_is_exceeded() {
		var child = new TestNode(NODE_STATUS.RUNNING);
		var timeout = new TimeoutNode(child, 1);

		timeout.execute(0);
		timeout.execute(0.5);
		var status = timeout.execute(0.75);

		Assert.equals(NODE_STATUS.FAILURE, status);
		Assert.equals(1, child.halted);
		Assert.equals(2, child.executed);
	}

	public function test_a_child_needing_exactly_the_limit_finishes() {
		var timeout = new TimeoutNode(new WaitNode(1), 1);

		timeout.execute(0);
		timeout.execute(0.5);

		Assert.equals(NODE_STATUS.SUCCESS, timeout.execute(0.5));
	}

	public function test_a_zero_limit_still_runs_the_child_once() {
		var child = new TestNode(NODE_STATUS.RUNNING);
		var timeout = new TimeoutNode(child, 0);

		Assert.equals(NODE_STATUS.RUNNING, timeout.execute(0.5));
		Assert.equals(NODE_STATUS.FAILURE, timeout.execute(0.5));
		Assert.equals(1, child.executed);
	}

	public function test_each_run_gets_the_full_limit() {
		var child = new TestNode(NODE_STATUS.RUNNING);
		var timeout = new TimeoutNode(child, 1);
		timeout.execute(0);
		timeout.execute(0.75);
		child.execReturn = NODE_STATUS.SUCCESS;
		timeout.execute(0);

		child.execReturn = NODE_STATUS.RUNNING;
		timeout.execute(0);

		Assert.equals(NODE_STATUS.RUNNING, timeout.execute(0.75));
		Assert.equals(0, child.halted);
	}

	public function test_timeout_starts_afresh_after_timing_out() {
		var child = new TestNode(NODE_STATUS.RUNNING);
		var timeout = new TimeoutNode(child, 1);
		timeout.execute(0);
		timeout.execute(2);

		Assert.equals(NODE_STATUS.RUNNING, timeout.execute(2));
		Assert.equals(NODE_STATUS.RUNNING, timeout.execute(1));
	}

	public function test_halting_a_timeout_halts_the_child_and_forgets_the_time_used() {
		var child = new TestNode(NODE_STATUS.RUNNING);
		var timeout = new TimeoutNode(child, 1);
		timeout.init(new Blackboard());
		timeout.execute(0);
		timeout.execute(0.75);

		timeout.halt();

		Assert.equals(1, child.halted);
		timeout.execute(0);
		Assert.equals(NODE_STATUS.RUNNING, timeout.execute(0.75));
	}

	public function test_timeout_passes_delta_time_to_the_child() {
		var child = new TestNode(NODE_STATUS.RUNNING);
		var timeout = new TimeoutNode(child, 1);

		timeout.execute(0.25);

		Assert.equals(0.25, child.lastDeltaTime);
	}

	public function test_timeout_rejects_a_limit_that_is_negative_or_not_finite() {
		Assert.raises(() -> new TimeoutNode(new TestNode(), -0.5));
		Assert.raises(() -> new TimeoutNode(new TestNode(), Math.NaN));
		Assert.raises(() -> new TimeoutNode(new TestNode(), Math.NEGATIVE_INFINITY));
	}
}
