package bt.node.composite;

import utest.Test;
import utest.Assert;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.bt.node.composite.ParallelNode;

class ParallelNodeTests extends Test {
	private function _parallel(children:Array<Node>, ?successThreshold:Int, ?failureThreshold:Int):ParallelNode {
		var parallel = new ParallelNode(children, successThreshold, failureThreshold);
		parallel.init(new Blackboard());
		return parallel;
	}

	public function test_when_every_child_succeeds_it_succeeds() {
		var first = new TestNode();
		var second = new TestNode();

		var status = _parallel([first, second]).execute(0);

		Assert.equals(NODE_STATUS.SUCCESS, status);
		Assert.equals(1, first.executed);
		Assert.equals(1, second.executed);
	}

	public function test_it_is_running_while_any_child_needed_for_success_is_running() {
		var parallel = _parallel([new TestNode(), new TestNode(NODE_STATUS.RUNNING)]);

		Assert.equals(NODE_STATUS.RUNNING, parallel.execute(0));
	}

	public function test_by_default_one_failing_child_fails_it_and_halts_running_siblings() {
		var running = new TestNode(NODE_STATUS.RUNNING);
		var failing = new TestNode(NODE_STATUS.RUNNING);
		var parallel = _parallel([running, failing]);

		parallel.execute(0);
		failing.execReturn = NODE_STATUS.FAILURE;
		var status = parallel.execute(0);

		Assert.equals(NODE_STATUS.FAILURE, status);
		Assert.equals(1, running.halted);
		Assert.equals(0, failing.halted);
	}

	public function test_a_success_threshold_of_one_succeeds_when_any_child_succeeds_and_halts_the_others() {
		var first = new TestNode(NODE_STATUS.RUNNING);
		var second = new TestNode(NODE_STATUS.RUNNING);
		var third = new TestNode(NODE_STATUS.RUNNING);
		var parallel = _parallel([first, second, third], 1);

		parallel.execute(0);
		second.execReturn = NODE_STATUS.SUCCESS;
		var status = parallel.execute(0);

		Assert.equals(NODE_STATUS.SUCCESS, status);
		Assert.equals(1, first.halted);
		Assert.equals(0, second.halted);
		Assert.equals(1, third.halted);
		Assert.equals(1, third.executed);
	}

	public function test_a_finished_child_is_not_ticked_again_while_others_run() {
		var finished = new TestNode();
		var running = new TestNode(NODE_STATUS.RUNNING);
		var parallel = _parallel([finished, running]);

		parallel.execute(0);
		parallel.execute(0);
		parallel.execute(0);

		Assert.equals(1, finished.executed);
		Assert.equals(3, running.executed);
	}

	public function test_it_fails_early_when_the_success_threshold_can_no_longer_be_reached() {
		var running = new TestNode(NODE_STATUS.RUNNING);
		var parallel = _parallel([running, new TestNode(NODE_STATUS.FAILURE), new TestNode(NODE_STATUS.FAILURE)], 2, 3);

		var status = parallel.execute(0);

		Assert.equals(NODE_STATUS.FAILURE, status);
		Assert.equals(1, running.halted);
	}

	public function test_failures_below_both_limits_keep_it_running() {
		var parallel = _parallel([new TestNode(NODE_STATUS.FAILURE), new TestNode(NODE_STATUS.RUNNING), new TestNode(NODE_STATUS.RUNNING)], 2, 2);

		Assert.equals(NODE_STATUS.RUNNING, parallel.execute(0));
	}

	public function test_halting_it_halts_running_children_and_the_next_execute_starts_afresh() {
		var finished = new TestNode();
		var running = new TestNode(NODE_STATUS.RUNNING);
		var parallel = _parallel([finished, running]);

		parallel.execute(0);
		parallel.halt();
		parallel.execute(0);

		Assert.equals(1, running.halted);
		Assert.equals(0, finished.halted);
		Assert.equals(2, finished.executed);
	}

	public function test_after_deciding_the_next_execute_starts_afresh() {
		var child = new TestNode();
		var parallel = _parallel([child]);

		parallel.execute(0);
		parallel.execute(0);

		Assert.equals(2, child.executed);
	}

	public function test_with_no_children_it_succeeds() {
		Assert.equals(NODE_STATUS.SUCCESS, _parallel([]).execute(0));
	}

	public function test_a_threshold_outside_one_to_the_child_count_throws() {
		var children:Array<Node> = [new TestNode(), new TestNode()];

		Assert.raises(() -> new ParallelNode(children, 0));
		Assert.raises(() -> new ParallelNode(children, 3));
		Assert.raises(() -> new ParallelNode(children, null, 0));
		Assert.raises(() -> new ParallelNode(children, null, 3));
		Assert.raises(() -> new ParallelNode([], 1));
	}

	public function test_thresholds_default_to_every_child_for_success_and_one_for_failure() {
		var parallel = new ParallelNode([new TestNode(), new TestNode(), new TestNode()]);

		Assert.equals(3, parallel.successThreshold);
		Assert.equals(1, parallel.failureThreshold);
	}

	public function test_delta_time_reaches_every_child() {
		var first = new TestNode(NODE_STATUS.RUNNING);
		var second = new TestNode();

		_parallel([first, second]).execute(0.25);

		Assert.equals(0.25, first.lastDeltaTime);
		Assert.equals(0.25, second.lastDeltaTime);
	}
}
