package goap;

import utest.Test;
import utest.Assert;
import dropecho.ai.goap.Action;

class ActionTests extends Test {
	var _action:Action;
	var _counter:Int = 0;

	public function setup() {
		_counter = 0;

		_action = new Action("test_action", (deltaTime) -> _counter = 1);
		_action.PreMatcher = function() {
			_counter = -1;
			return false;
		}
		_action.PostMatcher = function() {
			_counter = -2;
			return false;
		}
	}

	public function test_update_calls_given_func() {
		_action.update(0);
		Assert.equals(1, _counter);
	}

	public function test_preconditions_satisfied_calls_pre_matcher() {
		_action.preconditions_satisfied();
		Assert.equals(-1, _counter);
	}

	public function test_postconditions_satisfied_calls_post_matcher() {
		_action.postconditions_satisfied();
		Assert.equals(-2, _counter);
	}

	public function test_cost_defaults_to_zero() {
		var a = new Action("t", _ -> {});
		Assert.equals(0.0, a.Cost);
	}

	public function test_preconditions_default_to_empty() {
		var a = new Action("t", _ -> {});
		Assert.equals(0, a.Preconditions.length);
	}

	public function test_postconditions_default_to_empty() {
		var a = new Action("t", _ -> {});
		Assert.equals(0, a.Postconditions.length);
	}

	public function test_pre_matcher_defaults_to_true() {
		var a = new Action("t", _ -> {});
		Assert.isTrue(a.preconditions_satisfied());
	}

	public function test_post_matcher_defaults_to_true() {
		var a = new Action("t", _ -> {});
		Assert.isTrue(a.postconditions_satisfied());
	}
}
