package goap;

import utest.Test;
import utest.Assert;
import dropecho.ai.goap.Planner;
import dropecho.ai.goap.Plan;
import dropecho.ai.goap.Action;
import dropecho.ai.goap.State;

class PlannerTests extends Test {
	private var _planner:Planner;
	private var _plan:Plan;
	private var _actionDone:Bool = false;
	private var _action1:Action;
	private var _action2:Action;
	private var _goal:State;

	public function setup() {
		_actionDone = false;
		_action1 = new Action("test_action", deltaTime -> _actionDone = true, 1);
		_action2 = new Action("test_action2", deltaTime -> _actionDone = true, 0);
		_goal = new State(["test_condition"]);
	}

	public function test_when_given_no_matching_actions_plan_should_be_null() {
		_planner = new Planner(_goal, [_action1]);
		_plan = _planner.generatePlan();
		Assert.isTrue(_plan == null);
	}

	public function test_when_given_a_matching_action_plan_should_be_generated() {
		_action1.Postconditions = ["test_condition"];
		_planner = new Planner(_goal, [_action1]);
		_plan = _planner.generatePlan();

		Assert.isTrue(_plan != null);
	}

	public function test_when_given_two_matching_actions_plan_should_contain_lowest_cost_action() {
		_action1.Postconditions = ["test_condition"];
		_action2.Postconditions = ["test_condition"];
		_planner = new Planner(_goal, [_action1, _action2]);
		_plan = _planner.generatePlan();

		Assert.equals(_plan.Actions[0], _action2);
	}
}
