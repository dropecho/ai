package dropecho.ai.bt.node;

/**
 * Checks the lengths of time given to time-based nodes (Wait, Timeout, Cooldown).
 */
class Duration {
	/**
	 * Throws a message explaining the rule unless `value` is a finite number of at least zero.
	 *
	 * @param value - The length of time, in the game's time unit (the unit it passes as deltaTime).
	 * @param description - What the value is, e.g. "WaitNode duration".
	 * @param example - A constructor call showing a valid value, e.g. "new WaitNode(2.5)".
	 * @return `value`, unchanged.
	 */
	public static function check(value:Float, description:String, example:String):Float {
		var isValidDuration = Math.isFinite(value) && value >= 0;
		if (isValidDuration == false) {
			throw '$description must be a finite number of at least 0, but got $value. '
				+ 'It is measured in the same time unit the game passes as deltaTime (e.g. seconds): $example.';
		}

		return value;
	}
}
