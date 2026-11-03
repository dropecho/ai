package bt.node;

import utest.Test;
import utest.Assert;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.bt.node.WaitNode;
import dropecho.ai.bt.node.composite.SequenceNode;

class WaitNodeTests extends Test {
	public function test_wait_is_running_on_the_tick_it_starts() {
		var wait = new WaitNode(1);

		Assert.equals(NODE_STATUS.RUNNING, wait.execute(5));
	}

	public function test_wait_succeeds_on_the_tick_the_waited_time_reaches_the_duration() {
		var wait = new WaitNode(1);

		wait.execute(0.5);
		Assert.equals(NODE_STATUS.RUNNING, wait.execute(0.5));
		Assert.equals(NODE_STATUS.SUCCESS, wait.execute(0.5));
	}

	public function test_wait_adds_up_uneven_ticks() {
		var wait = new WaitNode(1);

		wait.execute(0);
		Assert.equals(NODE_STATUS.RUNNING, wait.execute(0.25));
		Assert.equals(NODE_STATUS.RUNNING, wait.execute(0.5));
		Assert.equals(NODE_STATUS.SUCCESS, wait.execute(0.75));
	}

	public function test_a_zero_wait_succeeds_on_its_first_tick() {
		var wait = new WaitNode(0);

		Assert.equals(NODE_STATUS.SUCCESS, wait.execute(0));
	}

	public function test_wait_starts_afresh_after_succeeding() {
		var wait = new WaitNode(1);
		wait.execute(0);
		wait.execute(1);

		Assert.equals(NODE_STATUS.RUNNING, wait.execute(1));
		Assert.equals(NODE_STATUS.SUCCESS, wait.execute(1));
	}

	public function test_halting_a_wait_forgets_the_time_waited() {
		var wait = new WaitNode(1);
		wait.execute(0);
		wait.execute(0.75);

		wait.halt();

		Assert.equals(NODE_STATUS.RUNNING, wait.execute(0.75));
		Assert.equals(NODE_STATUS.RUNNING, wait.execute(0.25));
		Assert.equals(NODE_STATUS.SUCCESS, wait.execute(0.75));
	}

	public function test_wait_in_a_sequence_holds_up_the_next_child() {
		var after = new TestNode();
		var sequence = new SequenceNode([new WaitNode(1), after]);
		sequence.init(new Blackboard());

		sequence.execute(0);
		sequence.execute(0.5);
		Assert.equals(0, after.executed);

		Assert.equals(NODE_STATUS.SUCCESS, sequence.execute(0.5));
		Assert.equals(1, after.executed);
	}

	public function test_wait_rejects_a_negative_duration() {
		Assert.raises(() -> new WaitNode(-1));
	}

	public function test_wait_rejects_a_duration_that_is_not_a_finite_number() {
		Assert.raises(() -> new WaitNode(Math.NaN));
		Assert.raises(() -> new WaitNode(Math.POSITIVE_INFINITY));
	}
}
