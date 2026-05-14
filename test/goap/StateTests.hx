package goap;

import utest.Test;
import utest.Assert;
import dropecho.ai.goap.State;

class StateTests extends Test {
	public function test_preconditions_are_stored() {
		var s = new State(["cond_a", "cond_b"]);
		Assert.equals(2, s.Preconditions.length);
		Assert.equals("cond_a", s.Preconditions[0]);
		Assert.equals("cond_b", s.Preconditions[1]);
	}

	public function test_relevance_defaults_to_zero() {
		var s = new State(["cond"]);
		Assert.equals(0, s.Relevance);
	}

	public function test_relevance_can_be_set() {
		var s = new State(["cond"], 5);
		Assert.equals(5, s.Relevance);
	}

	public function test_empty_preconditions() {
		var s = new State([]);
		Assert.equals(0, s.Preconditions.length);
	}
}
