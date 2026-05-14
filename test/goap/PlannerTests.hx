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

	public function test_when_given_empty_action_list_plan_should_be_null() {
		_planner = new Planner(_goal, []);
		_plan = _planner.generatePlan();
		Assert.isNull(_plan);
	}

	public function test_when_goal_already_satisfied_by_start_state_plan_is_empty() {
		// Goal with no preconditions is satisfied by the empty start state
		var emptyGoal = new State([]);
		_planner = new Planner(emptyGoal, [_action1]);
		_plan = _planner.generatePlan();
		Assert.notNull(_plan);
		Assert.equals(0, _plan.length);
	}

	public function test_globally_cheapest_plan_chosen_over_greedy() {
		// Two paths to the goal:
		//   Path A: direct action, cost 10
		//   Path B: two actions, cost 1 + 1 = 2 (cheaper overall)
		// A greedy-per-step planner would pick Path A; graph Dijkstra picks Path B.
		var directAction = new Action("direct", _ -> {}, 10, [], ["goal_met"]);
		var step1 = new Action("step1", _ -> {}, 1, [], ["intermediate"]);
		var step2 = new Action("step2", _ -> {}, 1, ["intermediate"], ["goal_met"]);
		var goal = new State(["goal_met"]);

		_planner = new Planner(goal, [directAction, step1, step2]);
		_plan = _planner.generatePlan();

		Assert.notNull(_plan);
		Assert.equals(2, _plan.length);
		Assert.equals(step1, _plan._actions.dequeue());
		Assert.equals(step2, _plan._actions.dequeue());
	}

	public function test_circular_dependencies_do_not_infinite_loop() {
		// Action A needs "b", produces "a". Action B needs "a", produces "b".
		// Circular — no valid plan. Should return null without hanging.
		var actionA = new Action("a", _ -> {}, 1, ["b"], ["a"]);
		var actionB = new Action("b", _ -> {}, 1, ["a"], ["b"]);
		var goal = new State(["a"]);

		_planner = new Planner(goal, [actionA, actionB]);
		_plan = _planner.generatePlan();
		Assert.isNull(_plan);
	}
}
