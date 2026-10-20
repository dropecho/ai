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

	public function test_keys_is_empty_for_new_blackboard() {
		Assert.same([], bb.keys());
	}

	public function test_keys_lists_set_facts_sorted() {
		bb.set("thirst", 1.0);
		bb.set("hunger", 2.0);
		bb.increment("energy");
		Assert.same(["energy", "hunger", "thirst"], bb.keys());
	}

	public function test_keys_skips_facts_only_read() {
		bb.get("missing");
		Assert.same([], bb.keys());
	}

	public function test_keys_lists_each_fact_once() {
		bb.set("key", 1.0);
		bb.set("key", 2.0);
		Assert.same(["key"], bb.keys());
	}

	public function test_keys_returns_a_copy() {
		bb.set("key", 1.0);
		bb.keys().push("other");
		Assert.same(["key"], bb.keys());
	}
}
