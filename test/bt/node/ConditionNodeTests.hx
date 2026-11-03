package bt.node;

import utest.Test;
import utest.Assert;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.ConditionNode;
import dropecho.ai.bt.node.NODE_STATUS;

class ConditionNodeTests extends Test {
	public function test_a_true_check_succeeds() {
		var condition = new ConditionNode(context -> true);
		condition.init(new Blackboard());

		Assert.equals(NODE_STATUS.SUCCESS, condition.execute(0));
	}

	public function test_a_false_check_fails() {
		var condition = new ConditionNode(context -> false);
		condition.init(new Blackboard());

		Assert.equals(NODE_STATUS.FAILURE, condition.execute(0));
	}

	public function test_the_check_is_given_the_blackboard() {
		var blackboard = new Blackboard();
		var given:Blackboard = null;
		var condition = new ConditionNode(function(context) {
			given = context;
			return true;
		});
		condition.init(blackboard);

		condition.execute(0);

		Assert.equals(blackboard, given);
	}

	public function test_the_check_is_asked_every_tick() {
		var asked = 0;
		var condition = new ConditionNode(function(context) {
			asked++;
			return asked > 1;
		});
		condition.init(new Blackboard());

		var first = condition.execute(0);
		var second = condition.execute(0);

		Assert.equals(NODE_STATUS.FAILURE, first);
		Assert.equals(NODE_STATUS.SUCCESS, second);
	}
}
