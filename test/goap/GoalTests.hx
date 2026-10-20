package goap;

import utest.Test;
import utest.Assert;
import dropecho.ai.goap.Goal;

class GoalTests extends Test {
	public function test_conditions_are_stored() {
		var goal = new Goal(["cond_a", "cond_b"]);
		Assert.same(["cond_a", "cond_b"], goal.conditions);
	}

	public function test_empty_conditions() {
		var goal = new Goal([]);
		Assert.equals(0, goal.conditions.length);
	}
}
