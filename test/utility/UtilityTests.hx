package utility;

import dropecho.ai.utility.Motive;
import dropecho.ai.utility.Motive.UtilityAgent;
import utest.Test;
import utest.Assert;

class UtilityTests extends Test {
	public function test_lowest() {
		var util = new UtilityAgent();

		var hunger = new Motive("hunger", 0.5);
		var thirst = new Motive("thirst", 1);

		util.motives.push(hunger);
		util.motives.push(thirst);

		var lowest = util.getMostImportantMotive();
		Assert.equals(hunger, lowest);
	}

	public function test_empty_motives_returns_null() {
		var util = new UtilityAgent();
		var result = util.getMostImportantMotive();
		Assert.isNull(result);
	}

	public function test_single_motive_returns_that_motive() {
		var util = new UtilityAgent();
		var hunger = new Motive("hunger", 0.5);
		util.motives.push(hunger);
		var result = util.getMostImportantMotive();
		Assert.equals(hunger, result);
	}

	public function test_equal_values_returns_the_first_motive() {
		var util = new UtilityAgent();
		var a = new Motive("a", 0.5);
		var b = new Motive("b", 0.5);
		var c = new Motive("c", 0.5);
		util.motives.push(a);
		util.motives.push(b);
		util.motives.push(c);
		var result = util.getMostImportantMotive();
		Assert.equals(a, result);
	}

	public function test_tie_for_lowest_returns_the_first_of_the_tied() {
		var util = new UtilityAgent();
		var high = new Motive("high", 0.9);
		var first = new Motive("first", 0.2);
		var second = new Motive("second", 0.2);
		util.motives.push(high);
		util.motives.push(first);
		util.motives.push(second);
		var result = util.getMostImportantMotive();
		Assert.equals(first, result);
	}

	public function test_lowest_value_first_in_list() {
		var util = new UtilityAgent();
		var low = new Motive("low", 0.1);
		var high = new Motive("high", 0.9);
		util.motives.push(low);
		util.motives.push(high);
		var result = util.getMostImportantMotive();
		Assert.equals(low, result);
	}
}
