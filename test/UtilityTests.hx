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
}
