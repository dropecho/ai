package bt.node.decorator;

import utest.Test;
import utest.Assert;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.bt.node.composite.SelectorNode;
import dropecho.ai.bt.node.composite.SequenceNode;
import dropecho.ai.bt.node.decorator.AbortMode;
import dropecho.ai.bt.node.decorator.GuardNode;
import bt.node.TestNode;

class AbortModeTests extends Test {
	private var isAllowed:Bool;
	private var guarded:TestNode;
	private var lowPriority:TestNode;

	public function setup() {
		isAllowed = false;
		guarded = new TestNode(NODE_STATUS.RUNNING);
		lowPriority = new TestNode(NODE_STATUS.RUNNING);
	}

	private function selectorWithGuard(abort:AbortMode):SelectorNode {
		var guard = new GuardNode(context -> isAllowed, guarded, abort);
		var selector = new SelectorNode([guard, lowPriority]);
		selector.init(new Blackboard());
		return selector;
	}

	public function test_none_asks_the_check_only_when_the_child_is_not_running() {
		isAllowed = true;
		var guard = new GuardNode(context -> isAllowed, guarded, AbortMode.NONE);
		guard.init(new Blackboard());

		guard.execute(0);
		isAllowed = false;
		var status = guard.execute(0);

		Assert.equals(NODE_STATUS.RUNNING, status);
		Assert.equals(0, guarded.halted);
		Assert.equals(2, guarded.executed);
	}

	public function test_none_asks_the_check_again_once_the_child_finishes() {
		isAllowed = true;
		guarded.execReturn = NODE_STATUS.SUCCESS;
		var guard = new GuardNode(context -> isAllowed, guarded, AbortMode.NONE);
		guard.init(new Blackboard());

		guard.execute(0);
		isAllowed = false;

		Assert.equals(NODE_STATUS.FAILURE, guard.execute(0));
	}

	public function test_lower_priority_in_a_selector_halts_the_low_branch_and_runs_the_guarded_one_the_same_tick() {
		var selector = selectorWithGuard(AbortMode.LOWER_PRIORITY);

		selector.execute(0);
		isAllowed = true;
		var status = selector.execute(0);

		Assert.equals(NODE_STATUS.RUNNING, status);
		Assert.equals(1, lowPriority.halted);
		Assert.equals(1, lowPriority.executed);
		Assert.equals(1, guarded.executed);
	}

	public function test_lower_priority_keeps_the_low_branch_while_the_check_stays_false() {
		var selector = selectorWithGuard(AbortMode.LOWER_PRIORITY);

		selector.execute(0);
		selector.execute(0);

		Assert.equals(0, lowPriority.halted);
		Assert.equals(2, lowPriority.executed);
	}

	public function test_lower_priority_does_not_abort_when_the_guarded_child_failed_with_a_true_check() {
		isAllowed = true;
		guarded.execReturn = NODE_STATUS.FAILURE;
		var selector = selectorWithGuard(AbortMode.LOWER_PRIORITY);

		selector.execute(0);
		selector.execute(0);

		Assert.equals(0, lowPriority.halted);
		Assert.equals(1, guarded.executed);
	}

	public function test_lower_priority_without_self_does_not_halt_its_own_running_child() {
		isAllowed = true;
		var selector = selectorWithGuard(AbortMode.LOWER_PRIORITY);

		selector.execute(0);
		isAllowed = false;
		var status = selector.execute(0);

		Assert.equals(NODE_STATUS.RUNNING, status);
		Assert.equals(0, guarded.halted);
	}

	public function test_none_does_not_abort_lower_priority() {
		var selector = selectorWithGuard(AbortMode.NONE);

		selector.execute(0);
		isAllowed = true;
		selector.execute(0);

		Assert.equals(0, lowPriority.halted);
		Assert.equals(0, guarded.executed);
	}

	public function test_self_does_not_abort_lower_priority() {
		var selector = selectorWithGuard(AbortMode.SELF);

		selector.execute(0);
		isAllowed = true;
		selector.execute(0);

		Assert.equals(0, lowPriority.halted);
	}

	public function test_both_aborts_lower_priority() {
		var selector = selectorWithGuard(AbortMode.BOTH);

		selector.execute(0);
		isAllowed = true;
		selector.execute(0);

		Assert.equals(1, lowPriority.halted);
		Assert.equals(1, guarded.executed);
	}

	public function test_both_aborts_self() {
		isAllowed = true;
		var selector = selectorWithGuard(AbortMode.BOTH);

		selector.execute(0);
		isAllowed = false;
		var status = selector.execute(0);

		Assert.equals(NODE_STATUS.RUNNING, status);
		Assert.equals(1, guarded.halted);
		Assert.equals(1, lowPriority.executed);
	}

	public function test_lower_priority_in_a_sequence_fails_it_when_the_check_turns_false() {
		isAllowed = true;
		guarded.execReturn = NODE_STATUS.SUCCESS;
		var guard = new GuardNode(context -> isAllowed, guarded, AbortMode.LOWER_PRIORITY);
		var sequence = new SequenceNode([guard, lowPriority]);
		sequence.init(new Blackboard());

		sequence.execute(0);
		isAllowed = false;
		var status = sequence.execute(0);

		Assert.equals(NODE_STATUS.FAILURE, status);
		Assert.equals(1, lowPriority.halted);
	}

	public function test_lower_priority_in_a_sequence_keeps_the_running_child_while_the_check_stays_true() {
		isAllowed = true;
		guarded.execReturn = NODE_STATUS.SUCCESS;
		var guard = new GuardNode(context -> isAllowed, guarded, AbortMode.LOWER_PRIORITY);
		var sequence = new SequenceNode([guard, lowPriority]);
		sequence.init(new Blackboard());

		sequence.execute(0);
		var status = sequence.execute(0);

		Assert.equals(NODE_STATUS.RUNNING, status);
		Assert.equals(0, lowPriority.halted);
		Assert.equals(1, guarded.executed);
	}

	public function test_a_reactive_selector_needs_no_abort_mode_to_take_over() {
		var guard = new GuardNode(context -> isAllowed, guarded, AbortMode.NONE);
		var selector = new SelectorNode([guard, lowPriority], true);
		selector.init(new Blackboard());

		selector.execute(0);
		isAllowed = true;
		selector.execute(0);

		Assert.equals(1, lowPriority.halted);
		Assert.equals(1, guarded.executed);
	}
}
