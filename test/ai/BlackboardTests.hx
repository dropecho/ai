package ai;

import utest.Assert;
import dropecho.ai.Blackboard;

class BlackboardTests extends utest.Test {
	private var bb:Blackboard;

	public function setup() {
		bb = new Blackboard();
	}

	public function test_get_returns_zero_for_missing_key() {
		Assert.equals(0, bb.get("missing"));
	}

	public function test_set_and_get_roundtrip() {
		bb.set("key", 42.0);
		Assert.equals(42.0, bb.get("key"));
	}

	public function test_increment_increases_value() {
		bb.set("key", 1.0);
		bb.increment("key");
		Assert.equals(2.0, bb.get("key"));
	}

	public function test_decrement_decreases_value() {
		bb.set("key", 2.0);
		bb.decrement("key");
		Assert.equals(1.0, bb.get("key"));
	}

	public function test_increment_from_zero() {
		bb.increment("never_set");
		Assert.equals(1.0, bb.get("never_set"));
	}
}
