package goap;

import utest.Test;
import utest.Assert;
import dropecho.ai.goap.Plan;
import dropecho.ai.goap.Action;

class PlanTests extends Test {
	var _plan:Plan;
	var _actionDone:Bool = false;
	var _action1:Action;

	public function setup() {
		_actionDone = false;
		_action1 = new Action("test_action", deltaTime -> _actionDone = true);

		_plan = new Plan();
	}

	public function test_when_there_are_no_actions_in_a_plan_done_should_always_return_true() {
		Assert.isTrue(_plan.done());
	}

	public function test_when_given_an_action_with_preconditions_unmatched_done_should_return_false() {
		_action1.PostMatcher = () -> false;
		_plan.Actions.unshift(_action1);
		Assert.isFalse(_plan.done());
	}

	public function test_when_given_an_action_with_preconditions_matched_done_should_return_true() {
		_action1.PostMatcher = () -> true;
		_plan.Actions.unshift(_action1);
		Assert.isTrue(_plan.done());
	}

	public function test_when_checking_done_on_an_updated_action() {
		_action1.PostMatcher = () -> _actionDone;
		_plan.Actions.unshift(_action1);
		Assert.isFalse(_plan.done());
	}

	public function test_when_calling_update_it_should_call_update_on_the_current_action() {
		_action1.PostMatcher = () -> _actionDone;
		_plan.Actions.unshift(_action1);
		_plan.update(0);
		Assert.isTrue(_plan.done());
	}

	public function test_when_first_action_completes_second_gets_ticked() {
		var action2Done = false;
		var action2 = new Action("second", _ -> action2Done = true);
		action2.PostMatcher = () -> action2Done;

		_action1.PostMatcher = () -> _actionDone;
		_plan = new Plan([_action1, action2]);

		// First update: ticks action1 (_actionDone = true) → action1 completes → action2 is now current
		_plan.update(0);
		Assert.isTrue(_actionDone);
		Assert.equals(1, _plan.length);

		// Second update: ticks action2 (action2Done = true) → action2 completes
		_plan.update(0);
		Assert.isTrue(action2Done);
		Assert.isTrue(_plan.isCompleted());
	}

	public function test_length_decrements_as_actions_complete() {
		var action2 = new Action("second", _ -> {});
		action2.PostMatcher = () -> true; // already satisfied

		_action1.PostMatcher = () -> _actionDone;
		_plan = new Plan([_action1, action2]);

		Assert.equals(2, _plan.length);

		// After update: action1 ticked (_actionDone=true) → both actions dequeued
		_plan.update(0);
		Assert.equals(0, _plan.length);
		Assert.isTrue(_plan.isCompleted());
	}
}
