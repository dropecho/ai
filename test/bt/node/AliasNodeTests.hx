package bt.node;

import utest.Test;
import utest.Assert;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.bt.node.composite.FallbackNode;
import dropecho.ai.bt.node.composite.SelectorNode;
import dropecho.ai.bt.node.decorator.ForceSuccessNode;
import dropecho.ai.bt.node.decorator.SucceederNode;
import dropecho.ai.bt.node.decorator.UntilFailureNode;
import dropecho.ai.bt.node.decorator.RepeatUntilNode;

class AliasNodeTests extends Test {
	public function test_force_success_is_a_succeeder() {
		var node = new ForceSuccessNode(new TestNode(NODE_STATUS.FAILURE));
		Assert.isTrue(Std.isOfType(node, SucceederNode));
		Assert.equals(NODE_STATUS.SUCCESS, node.execute(0));
	}

	public function test_until_failure_is_a_repeat_until_fail() {
		var child = new TestNode(NODE_STATUS.SUCCESS);
		var node = new UntilFailureNode(child);
		Assert.isTrue(Std.isOfType(node, RepeatUntilNode));
		Assert.equals(NODE_STATUS.RUNNING, node.execute(0));

		child.execReturn = NODE_STATUS.FAILURE;
		Assert.equals(NODE_STATUS.SUCCESS, node.execute(0));
	}

	public function test_fallback_is_a_selector() {
		var failing = new TestNode(NODE_STATUS.FAILURE);
		var succeeding = new TestNode(NODE_STATUS.SUCCESS);
		var node = new FallbackNode([failing, succeeding]);
		Assert.isTrue(Std.isOfType(node, SelectorNode));
		Assert.equals(NODE_STATUS.SUCCESS, node.execute(0));
		Assert.equals(1, failing.executed);
	}

	public function test_fallback_passes_on_the_reactive_flag() {
		var first = new TestNode(NODE_STATUS.FAILURE);
		var second = new TestNode(NODE_STATUS.RUNNING);
		var node = new FallbackNode([first, second], true);
		node.execute(0);
		node.execute(0);
		Assert.equals(2, first.executed);
	}
}
