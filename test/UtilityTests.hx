package;

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

		trace(util);

		var lowest = util.getMostImportantMotive();
		Assert.equals(lowest, hunger);
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

	public function test_equal_values_returns_a_motive() {
		var util = new UtilityAgent();
		var a = new Motive("a", 0.5);
		var b = new Motive("b", 0.5);
		util.motives.push(a);
		util.motives.push(b);
		var result = util.getMostImportantMotive();
		Assert.notNull(result);
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
