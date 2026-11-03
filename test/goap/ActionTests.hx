package goap;

import utest.Test;
import utest.Assert;
import dropecho.ai.goap.Action;

class ActionTests extends Test {
	var _action:Action;
	var _counter:Int = 0;

	public function setup() {
		_counter = 0;

		function startCheck() {
			_counter = -1;
			return false;
		}
		function doneCheck() {
			_counter = -2;
			return false;
		}

		function onUpdate(deltaTime) {
			_counter = 1;
		}

		_action = new Action("test_action", onUpdate, 0, [], [], startCheck, doneCheck);
	}

	public function test_update_calls_given_func() {
		_action.update(0);
		Assert.equals(1, _counter);
	}

	public function test_can_start_calls_the_start_check() {
		_action.canStart();
		Assert.equals(-1, _counter);
	}

	public function test_is_done_calls_the_done_check() {
		_action.isDone([]);
		Assert.equals(-2, _counter);
	}

	public function test_cost_defaults_to_zero() {
		var a = new Action("t", _ -> {});
		Assert.equals(0.0, a.cost);
	}

	public function test_preconditions_default_to_empty() {
		var a = new Action("t", _ -> {});
		Assert.equals(0, a.preconditions.length);
	}

	public function test_postconditions_default_to_empty() {
		var a = new Action("t", _ -> {});
		Assert.equals(0, a.postconditions.length);
	}

	public function test_start_check_defaults_to_true() {
		var a = new Action("t", _ -> {});
		Assert.isTrue(a.canStart());
	}

	public function test_done_check_defaults_to_none() {
		var a = new Action("t", _ -> {});
		Assert.isNull(a.doneCheck);
	}

	public function test_without_a_done_check_it_is_done_when_its_postconditions_are_in_the_world_state() {
		var a = new Action("t", _ -> {}, 0, [], ["x", "y"]);
		Assert.isFalse(a.isDone(["x"]));
		Assert.isTrue(a.isDone(["y", "x", "z"]));
	}

	public function test_with_a_done_check_it_ignores_the_world_state() {
		var a = new Action("t", _ -> {}, 0, [], ["x"], null, () -> false);
		Assert.isFalse(a.isDone(["x"]));
	}
}
