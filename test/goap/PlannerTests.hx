package goap;

import utest.Test;
import utest.Assert;
import dropecho.ai.goap.Planner;
import dropecho.ai.goap.Plan;
import dropecho.ai.goap.Action;
import dropecho.ai.goap.Goal;

class PlannerTests extends Test {
	private var _planner:Planner;
	private var _plan:Plan;
	private var _actionDone:Bool = false;
	private var _action1:Action;
	private var _action2:Action;
	private var _goal:Goal;

	public function setup() {
		_actionDone = false;
		_action1 = new Action("test_action", deltaTime -> _actionDone = true, 1);
		_action2 = new Action("test_action2", deltaTime -> _actionDone = true, 0);
		_goal = new Goal(["test_condition"]);
	}

	public function test_when_given_no_matching_actions_plan_should_be_null() {
		_planner = new Planner(_goal, [_action1], () -> []);
		_plan = _planner.generatePlan();
		Assert.equals(_plan, null);
	}

	public function test_when_given_a_matching_action_plan_should_be_generated() {
		_action1.postconditions = ["test_condition"];
		_planner = new Planner(_goal, [_action1], () -> []);
		_plan = _planner.generatePlan();

		Assert.notNull(_plan);
	}

	public function test_when_given_two_matching_actions_plan_should_contain_lowest_cost_action() {
		_action1.postconditions = ["test_condition"];
		_action2.postconditions = ["test_condition"];
		_planner = new Planner(_goal, [_action1, _action2], () -> []);
		_plan = _planner.generatePlan();

		Assert.equals(_action2, _plan.currentAction());
	}

	public function test_when_given_two_equal_cost_actions_plan_should_contain_the_first_given() {
		var first = new Action("first", _ -> {}, 1, [], ["test_condition"]);
		var second = new Action("second", _ -> {}, 1, [], ["test_condition"]);
		_planner = new Planner(_goal, [first, second], () -> []);
		_plan = _planner.generatePlan();

		Assert.equals(first, _plan.currentAction());
	}

	public function test_when_given_chained_actions_plan_should_contain_both_in_order() {
		var actionA = new Action("get_weapon", deltaTime -> {}, 1, ["found_weapon"], ["has_weapon"]);
		var actionB = new Action("find_weapon", deltaTime -> {}, 1, [], ["found_weapon"]);
		var goal = new Goal(["has_weapon"]);
		_planner = new Planner(goal, [actionA, actionB], () -> []);
		_plan = _planner.generatePlan();

		Assert.notNull(_plan);
		Assert.equals(2, _plan.length());
		Assert.same([actionB, actionA], [for (action in _plan) action]);
	}

	public function test_when_given_empty_action_list_plan_should_be_null() {
		_planner = new Planner(_goal, []);
		_plan = _planner.generatePlan();
		Assert.isNull(_plan);
	}

	public function test_when_goal_already_satisfied_by_start_state_plan_is_empty() {
		// Goal with no preconditions is satisfied by the empty start state
		var emptyGoal = new Goal([]);
		_planner = new Planner(emptyGoal, [_action1], () -> []);
		_plan = _planner.generatePlan();
		Assert.notNull(_plan);
		Assert.equals(0, _plan.length());
	}

	public function test_globally_cheapest_plan_chosen_over_greedy() {
		// Two paths to the goal:
		//   Path A: direct action, cost 10
		//   Path B: two actions, cost 1 + 1 = 2 (cheaper overall)
		// A greedy-per-step planner would pick Path A; graph Dijkstra picks Path B.
		var directAction = new Action("direct", _ -> {}, 10, [], ["goal_met"]);
		var step1 = new Action("step1", _ -> {}, 1, [], ["intermediate"]);
		var step2 = new Action("step2", _ -> {}, 1, ["intermediate"], ["goal_met"]);
		var goal = new Goal(["goal_met"]);

		_planner = new Planner(goal, [directAction, step1, step2], () -> []);
		_plan = _planner.generatePlan();

		Assert.notNull(_plan);
		Assert.equals(2, _plan.length());
		Assert.same([step1, step2], [for (action in _plan) action]);
	}

	public function test_circular_dependencies_do_not_infinite_loop() {
		// Action A needs "b", produces "a". Action B needs "a", produces "b".
		// Circular — no valid plan. Should return null without hanging.
		var actionA = new Action("a", _ -> {}, 1, ["b"], ["a"]);
		var actionB = new Action("b", _ -> {}, 1, ["a"], ["b"]);
		var goal = new Goal(["a"]);

		_planner = new Planner(goal, [actionA, actionB]);
		_plan = _planner.generatePlan();
		Assert.isNull(_plan);
	}

	public function test_a_condition_name_with_a_comma_is_not_two_condition_names() {
		var makeAB = new Action("make_a_comma_b", _ -> {}, 1, [], ["a,b"]);
		var makeA = new Action("make_a", _ -> {}, 1, [], ["a"]);
		var makeB = new Action("make_b", _ -> {}, 1, ["a"], ["b"]);
		_planner = new Planner(new Goal(["a", "b"]), [makeAB, makeA, makeB], () -> []);
		_plan = _planner.generatePlan();

		Assert.notNull(_plan);
		Assert.same([makeA, makeB], _plan.remainingActions());
	}

	public function test_plans_from_the_world_state_provider() {
		var findWeapon = new Action("find_weapon", _ -> {}, 1, [], ["found_weapon"]);
		var getWeapon = new Action("get_weapon", _ -> {}, 1, ["found_weapon"], ["has_weapon"]);
		_planner = new Planner(new Goal(["has_weapon"]), [findWeapon, getWeapon], () -> ["found_weapon"]);
		_plan = _planner.generatePlan();

		Assert.same([getWeapon], _plan.remainingActions());
	}

	public function test_goal_already_true_in_the_world_state_gives_an_empty_plan() {
		_planner = new Planner(_goal, [_action1], () -> ["test_condition"]);
		_plan = _planner.generatePlan();

		Assert.notNull(_plan);
		Assert.equals(0, _plan.length());
	}

	public function test_without_a_world_state_provider_it_plans_from_the_empty_world_state() {
		var needsKey = new Action("open_door", _ -> {}, 1, ["has_key"], ["test_condition"], null, () -> true);
		_planner = new Planner(_goal, [needsKey]);
		Assert.isNull(_planner.generatePlan());
	}

	public function test_the_plan_uses_the_planners_world_state_provider() {
		var worldState = [];
		_action1.postconditions = ["test_condition"];
		_planner = new Planner(_goal, [_action1], () -> worldState);
		_plan = _planner.generatePlan();
		Assert.isFalse(_plan.isCompleted());

		worldState = ["test_condition"];
		Assert.isTrue(_plan.isCompleted());
	}

	public function test_an_action_without_a_done_check_and_no_world_state_provider_throws() {
		_action1.postconditions = ["test_condition"];
		_planner = new Planner(_goal, [_action1]);
		Assert.raises(() -> _planner.generatePlan());
	}

	public function test_actions_with_their_own_done_checks_need_no_world_state_provider() {
		var action = new Action("act", _ -> {}, 1, [], ["test_condition"], null, () -> false);
		_planner = new Planner(_goal, [action]);
		_plan = _planner.generatePlan();
		Assert.isFalse(_plan.isCompleted());
	}
}
