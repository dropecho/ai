package ai;

import utest.Assert;
import dropecho.ai.Blackboard;
import dropecho.ai.BlackboardKey;

private class Entity {
	public final name:String;

	public function new(name:String) {
		this.name = name;
	}
}

private enum Mood {
	Calm;
	Angry(level:Int);
}

class BlackboardValueTests extends utest.Test {
	static final TARGET = new BlackboardKey<Entity>("target");
	static final MOOD = new BlackboardKey<Mood>("mood");
	static final PATROL = new BlackboardKey<{x:Int, y:Int}>("patrol");

	private var bb:Blackboard;

	public function setup() {
		bb = new Blackboard();
	}

	public function test_get_value_returns_null_for_missing_key() {
		Assert.isNull(bb.getValue(TARGET));
	}

	public function test_set_value_returns_the_value() {
		var enemy = new Entity("enemy");
		Assert.equals(enemy, bb.setValue(TARGET, enemy));
	}

	public function test_class_value_roundtrip() {
		var enemy = new Entity("enemy");
		bb.setValue(TARGET, enemy);
		var target:Entity = bb.getValue(TARGET);
		Assert.equals(enemy, target);
		Assert.equals("enemy", target.name);
	}

	public function test_enum_value_roundtrip() {
		bb.setValue(MOOD, Angry(3));
		Assert.same(Angry(3), bb.getValue(MOOD));
	}

	public function test_anonymous_value_roundtrip() {
		bb.setValue(PATROL, {x: 4, y: 7});
		Assert.equals(7, bb.getValue(PATROL).y);
	}

	public function test_a_string_names_the_same_value_as_a_key() {
		var enemy = new Entity("enemy");
		bb.setValue(TARGET, enemy);
		Assert.equals(enemy, bb.getValue(("target" : BlackboardKey<Entity>)));
	}

	public function test_has_value_is_false_for_missing_key() {
		Assert.isFalse(bb.hasValue(TARGET));
	}

	public function test_has_value_is_true_after_set_even_to_null() {
		bb.setValue(TARGET, null);
		Assert.isTrue(bb.hasValue(TARGET));
	}

	public function test_remove_value_makes_it_read_null() {
		bb.setValue(TARGET, new Entity("enemy"));
		Assert.isTrue(bb.removeValue(TARGET));
		Assert.isNull(bb.getValue(TARGET));
		Assert.isFalse(bb.hasValue(TARGET));
	}

	public function test_remove_value_returns_false_when_missing() {
		Assert.isFalse(bb.removeValue(TARGET));
	}

	public function test_values_and_facts_are_separate() {
		var count = new BlackboardKey<String>("count");
		bb.set("count", 3);
		bb.setValue(count, "three");
		Assert.equals(3, bb.get("count"));
		Assert.equals("three", bb.getValue(count));
	}

	public function test_keys_lists_only_facts() {
		bb.set("hunger", 1);
		bb.setValue(TARGET, new Entity("enemy"));
		Assert.same(["hunger"], bb.keys());
	}

	public function test_value_keys_lists_held_values_sorted() {
		bb.setValue(TARGET, new Entity("enemy"));
		bb.setValue(MOOD, Calm);
		bb.set("hunger", 1);
		Assert.same(["mood", "target"], bb.valueKeys());
	}

	public function test_value_keys_skips_removed_values() {
		bb.setValue(MOOD, Calm);
		bb.removeValue(MOOD);
		Assert.same([], bb.valueKeys());
	}
}
