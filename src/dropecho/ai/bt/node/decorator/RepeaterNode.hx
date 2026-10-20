package dropecho.ai.bt.node.decorator;

/**
 * A Repeater: runs its child again and again, forever or until it has succeeded a given number of times.
 * With a count, a child that finishes at once is run again in the same tick, so a count of 3 on an
 * instant child succeeds in one tick; a child FAILURE stops the Repeater with FAILURE.
 */
@:expose("bt.RepeaterNode")
class RepeaterNode extends DecoratorNode {
	private var times:Null<Int>;
	private var successes:Int = 0;
	private var childRunning:Bool = false;

	/**
	 * Creates a Repeater; throws if `times` is less than 1.
	 *
	 * @param child - The node to repeat.
	 * @param times - How many successes of the child finish the Repeater; leave out to repeat forever.
	 */
	public function new(child:Node, ?times:Int) {
		super(child);
		var isBelowOne = times != null && times < 1;
		if (isBelowOne) {
			throw 'RepeaterNode needs times of at least 1, but got $times. '
				+ 'Pass how many successes finish it, e.g. new RepeaterNode(child, 3), or leave times out to repeat forever.';
		}
		this.times = times;
	}

	/**
	 * Runs the child; with a count, keeps running it within this tick while it succeeds.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return Without a count, always RUNNING. With one: SUCCESS once the child has succeeded `times` times,
	 * FAILURE when the child fails, RUNNING while the child is running.
	 */
	public function execute(deltaTime:Float):NODE_STATUS {
		if (times == null) {
			var status = child.execute(deltaTime);
			childRunning = status == NODE_STATUS.RUNNING;
			return NODE_STATUS.RUNNING;
		}

		while (successes < times) {
			var status = child.execute(deltaTime);
			switch (status) {
				case NODE_STATUS.RUNNING:
					childRunning = true;
					return NODE_STATUS.RUNNING;

				case NODE_STATUS.FAILURE:
					reset();
					return NODE_STATUS.FAILURE;

				case NODE_STATUS.SUCCESS:
					successes++;
			}
		}

		reset();
		return NODE_STATUS.SUCCESS;
	}

	/**
	 * Halts the child if it is running and forgets how many times it has succeeded.
	 */
	override public function halt():Void {
		if (childRunning) {
			super.halt();
		}
		reset();
	}

	private function reset():Void {
		successes = 0;
		childRunning = false;
	}
}
