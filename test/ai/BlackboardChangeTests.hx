package ai;

import utest.Assert;
import dropecho.ai.Blackboard;
import dropecho.ai.BlackboardKey;

class BlackboardChangeTests extends utest.Test {
	static final NAME = new BlackboardKey<String>("name");

	private var bb:Blackboard;
	private var heard:Array<String>;

	public function setup() {
		bb = new Blackboard();
		heard = [];
	}

	function record(key:String):Void {
		heard.push(key);
	}

	public function test_set_tells_listener_once() {
		bb.onChange("hunger", record);
		bb.set("hunger", 2);
		Assert.same(["hunger"], heard);
	}

	public function test_set_to_the_same_number_is_not_a_change() {
		bb.set("hunger", 2);
		bb.onChange("hunger", record);
		bb.set("hunger", 2);
		Assert.same([], heard);
	}

	public function test_setting_a_missing_fact_to_zero_is_not_a_change() {
		bb.onChange("hunger", record);
		bb.set("hunger", 0);
		Assert.same([], heard);
	}

	public function test_increment_and_decrement_tell_listener() {
		bb.onChange("hunger", record);
		bb.increment("hunger");
		bb.decrement("hunger");
		Assert.same(["hunger", "hunger"], heard);
	}

	public function test_listener_hears_only_its_key() {
		bb.onChange("hunger", record);
		bb.set("thirst", 1);
		Assert.same([], heard);
	}

	public function test_set_value_tells_listener_once() {
		bb.onChange("name", record);
		bb.setValue(NAME, "ada");
		Assert.same(["name"], heard);
	}

	public function test_set_value_to_an_equal_value_is_not_a_change() {
		bb.setValue(NAME, "ada");
		bb.onChange("name", record);
		bb.setValue(NAME, "ada");
		Assert.same([], heard);
	}

	public function test_remove_value_tells_listener_when_it_held_a_value() {
		bb.setValue(NAME, "ada");
		bb.onChange("name", record);
		bb.removeValue(NAME);
		bb.removeValue(NAME);
		Assert.same(["name"], heard);
	}

	public function test_listener_hears_fact_and_value_of_the_same_name() {
		bb.onChange("name", record);
		bb.set("name", 1);
		bb.setValue(NAME, "ada");
		Assert.same(["name", "name"], heard);
	}

	public function test_listeners_are_called_in_order_added() {
		var order = [];
		bb.onChange("hunger", key -> order.push(1));
		bb.onChange("hunger", key -> order.push(2));
		bb.set("hunger", 1);
		Assert.same([1, 2], order);
	}

	public function test_removed_listener_is_not_called() {
		var remove = bb.onChange("hunger", record);
		remove();
		bb.set("hunger", 1);
		Assert.same([], heard);
	}

	public function test_removing_twice_does_nothing() {
		var remove = bb.onChange("hunger", record);
		bb.onChange("hunger", key -> heard.push("other"));
		remove();
		remove();
		bb.set("hunger", 1);
		Assert.same(["other"], heard);
	}

	public function test_listener_can_remove_itself_during_notification() {
		var remove = null;
		remove = bb.onChange("hunger", key -> {
			heard.push("once");
			remove();
		});
		bb.onChange("hunger", record);
		bb.set("hunger", 1);
		bb.set("hunger", 2);
		Assert.same(["once", "hunger", "hunger"], heard);
	}

	public function test_listener_removed_during_notification_is_not_called() {
		var removeSecond = null;
		bb.onChange("hunger", key -> removeSecond());
		removeSecond = bb.onChange("hunger", record);
		bb.set("hunger", 1);
		Assert.same([], heard);
	}

	public function test_listener_added_during_notification_waits_for_next_change() {
		var isAdded = false;
		bb.onChange("hunger", key -> {
			if (isAdded == false) {
				isAdded = true;
				bb.onChange("hunger", record);
			}
		});
		bb.set("hunger", 1);
		Assert.same([], heard);
		bb.set("hunger", 2);
		Assert.same(["hunger"], heard);
	}
}
