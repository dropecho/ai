package goap;

import utest.Test;
import utest.Assert;
import dropecho.ai.goap.Action;

class ActionTests extends Test {
	var _action:Action;
	var _counter:Int = 0;

	public function setup() {
		_counter = 0;

		function preMatcher() {
			_counter = -1;
			return false;
		}
		function postMatcher() {
			_counter = -2;
			return false;
		}

		function updateFunc(deltaTime) {
			_counter = 1;
		}

		_action = new Action("test_action", updateFunc, 0, [], [], preMatcher, postMatcher);
	}

	public function test_test_update_should_call_given_func() {
		_action.update(0);
		Assert.equals(1, _counter);
	}

	public function test_test_pre_conditions_satisfied_should_call_given_func() {
		_action.preconditions_satisfied();
		Assert.equals(-1, _counter);
	}

	public function test_test_post_conditions_satisfied_should_call_given_func() {
		_action.postconditions_satisfied();
		Assert.equals(-2, _counter);
	}
}
