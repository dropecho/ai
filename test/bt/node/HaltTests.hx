package bt.node;

import utest.Test;
import utest.Assert;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.BehaviorTree;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.bt.node.composite.SelectorNode;
import dropecho.ai.bt.node.composite.SequenceNode;
import dropecho.ai.bt.node.decorator.InverterNode;

class HaltTests extends Test {
	public function test_reactive_selector_halts_a_running_child_when_an_earlier_child_succeeds() {
		var guard = new TestNode(NODE_STATUS.FAILURE);
		var running = new TestNode(NODE_STATUS.RUNNING);
		var selector = new SelectorNode([guard, running], true);
		selector.init(new Blackboard());

		selector.execute(0);
		guard.execReturn = NODE_STATUS.SUCCESS;
		var status = selector.execute(0);

		Assert.equals(NODE_STATUS.SUCCESS, status);
		Assert.equals(1, running.halted);
	}

	public function test_reactive_sequence_halts_a_running_child_when_an_earlier_child_fails() {
		var condition = new TestNode(NODE_STATUS.SUCCESS);
		var running = new TestNode(NODE_STATUS.RUNNING);
		var sequence = new SequenceNode([condition, running], true);
		sequence.init(new Blackboard());

		sequence.execute(0);
		condition.execReturn = NODE_STATUS.FAILURE;
		var status = sequence.execute(0);

		Assert.equals(NODE_STATUS.FAILURE, status);
		Assert.equals(1, running.halted);
	}

	public function test_reactive_selector_halts_the_old_running_child_when_another_starts_running() {
		var first = new TestNode(NODE_STATUS.FAILURE);
		var second = new TestNode(NODE_STATUS.RUNNING);
		var selector = new SelectorNode([first, second], true);
		selector.init(new Blackboard());

		selector.execute(0);
		first.execReturn = NODE_STATUS.RUNNING;
		selector.execute(0);

		Assert.equals(1, second.halted);
		Assert.equals(0, first.halted);
	}

	public function test_resuming_the_same_running_child_does_not_halt_it() {
		var running = new TestNode(NODE_STATUS.RUNNING);
		var sequence = new SequenceNode([new TestNode(), running], true);
		sequence.init(new Blackboard());

		sequence.execute(0);
		sequence.execute(0);

		Assert.equals(0, running.halted);
	}

	public function test_a_child_that_finishes_on_its_own_is_not_halted() {
		var child = new TestNode(NODE_STATUS.RUNNING);
		var sequence = new SequenceNode([child]);
		sequence.init(new Blackboard());

		sequence.execute(0);
		child.execReturn = NODE_STATUS.SUCCESS;
		sequence.execute(0);

		Assert.equals(0, child.halted);
	}

	public function test_halting_a_composite_halts_its_running_child_and_restarts_it() {
		var first = new TestNode();
		var running = new TestNode(NODE_STATUS.RUNNING);
		var sequence = new SequenceNode([first, running]);
		sequence.init(new Blackboard());

		sequence.execute(0);
		sequence.halt();
		sequence.execute(0);

		Assert.equals(1, running.halted);
		Assert.equals(2, first.executed);
	}

	public function test_halting_an_idle_composite_halts_nothing() {
		var child = new TestNode();
		var sequence = new SequenceNode([child]);
		sequence.init(new Blackboard());

		sequence.execute(0);
		sequence.halt();

		Assert.equals(0, child.halted);
	}

	public function test_halting_a_decorator_halts_its_child() {
		var child = new TestNode(NODE_STATUS.RUNNING);
		var inverter = new InverterNode(child);
		inverter.init(new Blackboard());

		inverter.execute(0);
		inverter.halt();

		Assert.equals(1, child.halted);
	}

	public function test_halting_the_tree_halts_the_running_branch() {
		var running = new TestNode(NODE_STATUS.RUNNING);
		var tree = new BehaviorTree(new SequenceNode([running]));
		tree.init(new Blackboard());

		tree.execute(0);
		tree.halt();

		Assert.equals(1, running.halted);
	}

	public function test_delta_time_reaches_every_leaf() {
		var first = new TestNode();
		var second = new TestNode();
		var tree = new BehaviorTree(new SequenceNode([new InverterNode(new InverterNode(first)), second]));
		tree.init(new Blackboard());

		tree.execute(0.25);

		Assert.equals(0.25, first.lastDeltaTime);
		Assert.equals(0.25, second.lastDeltaTime);
	}
}
