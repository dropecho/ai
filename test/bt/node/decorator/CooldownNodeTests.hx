package bt.node.decorator;

import utest.Test;
import utest.Assert;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.NODE_STATUS;
import bt.node.TestNode;
import dropecho.ai.bt.node.decorator.CooldownNode;

class CooldownNodeTests extends Test {
	public function test_cooldown_passes_through_the_childs_status_when_not_cooling_down() {
		var child = new TestNode(NODE_STATUS.RUNNING);
		var cooldown = new CooldownNode(child, 1);

		Assert.equals(NODE_STATUS.RUNNING, cooldown.execute(0));
		child.execReturn = NODE_STATUS.SUCCESS;
		Assert.equals(NODE_STATUS.SUCCESS, cooldown.execute(0));
	}

	public function test_cooldown_fails_without_running_the_child_after_it_succeeds() {
		var child = new TestNode(NODE_STATUS.SUCCESS);
		var cooldown = new CooldownNode(child, 1);

		cooldown.execute(0);

		Assert.equals(NODE_STATUS.FAILURE, cooldown.execute(0.5));
		Assert.equals(1, child.executed);
	}

	public function test_cooldown_also_starts_after_the_child_fails() {
		var child = new TestNode(NODE_STATUS.FAILURE);
		var cooldown = new CooldownNode(child, 1);

		cooldown.execute(0);
		cooldown.execute(0.5);

		Assert.equals(1, child.executed);
	}

	public function test_child_runs_again_on_the_tick_the_cooldown_ends() {
		var child = new TestNode(NODE_STATUS.SUCCESS);
		var cooldown = new CooldownNode(child, 1);
		cooldown.execute(0);
		cooldown.execute(0.5);

		Assert.equals(NODE_STATUS.SUCCESS, cooldown.execute(0.5));
		Assert.equals(2, child.executed);
		Assert.equals(NODE_STATUS.FAILURE, cooldown.execute(0.5));
	}

	public function test_cooldown_does_not_start_while_the_child_is_running() {
		var child = new TestNode(NODE_STATUS.RUNNING);
		var cooldown = new CooldownNode(child, 1);

		cooldown.execute(0);
		cooldown.execute(5);

		Assert.equals(2, child.executed);
	}

	public function test_a_zero_cooldown_runs_the_child_every_tick() {
		var child = new TestNode(NODE_STATUS.SUCCESS);
		var cooldown = new CooldownNode(child, 0);

		cooldown.execute(0);
		cooldown.execute(0);

		Assert.equals(2, child.executed);
	}

	public function test_halting_a_cooldown_halts_its_running_child() {
		var child = new TestNode(NODE_STATUS.RUNNING);
		var cooldown = new CooldownNode(child, 1);
		cooldown.init(new Blackboard());
		cooldown.execute(0);

		cooldown.halt();

		Assert.equals(1, child.halted);
		Assert.equals(NODE_STATUS.RUNNING, cooldown.execute(0));
	}

	public function test_halting_a_cooldown_keeps_an_active_cooldown() {
		var child = new TestNode(NODE_STATUS.SUCCESS);
		var cooldown = new CooldownNode(child, 1);
		cooldown.execute(0);

		cooldown.halt();

		Assert.equals(NODE_STATUS.FAILURE, cooldown.execute(0.5));
		Assert.equals(1, child.executed);
	}

	public function test_cooldown_rejects_a_cooldown_that_is_negative_or_not_finite() {
		Assert.raises(() -> new CooldownNode(new TestNode(), -1));
		Assert.raises(() -> new CooldownNode(new TestNode(), Math.NaN));
		Assert.raises(() -> new CooldownNode(new TestNode(), Math.POSITIVE_INFINITY));
	}
}
