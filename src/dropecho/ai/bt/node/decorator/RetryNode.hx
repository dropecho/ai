package dropecho.ai.bt.node.decorator;

/**
 * A Retry: runs its child again when it fails, up to a number of attempts in total.
 * A failed attempt is retried in the same tick, so an instant child that always fails uses up
 * every attempt in one tick.
 */
@:expose("bt.RetryNode")
class RetryNode extends DecoratorNode {
	private var attempts:Int;
	private var failures:Int = 0;
	private var childRunning:Bool = false;

	/**
	 * Creates a Retry; throws if `attempts` is less than 1.
	 *
	 * @param child - The node to retry.
	 * @param attempts - How many times the child may run before the Retry gives up, counting the first.
	 */
	public function new(child:Node, attempts:Int) {
		super(child);
		var isBelowOne = attempts < 1;
		if (isBelowOne) {
			throw 'RetryNode needs attempts of at least 1, but got $attempts. '
				+ 'Pass how many times the child may run in total, e.g. new RetryNode(child, 3).';
		}
		this.attempts = attempts;
	}

	/**
	 * Runs the child, running it again within this tick while it fails and attempts remain.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return SUCCESS when the child succeeds, FAILURE when every attempt failed, RUNNING while the child is running.
	 */
	public function execute(deltaTime:Float):NODE_STATUS {
		while (failures < attempts) {
			var status = child.execute(deltaTime);
			switch (status) {
				case NODE_STATUS.RUNNING:
					childRunning = true;
					return NODE_STATUS.RUNNING;

				case NODE_STATUS.SUCCESS:
					reset();
					return NODE_STATUS.SUCCESS;

				case NODE_STATUS.FAILURE:
					failures++;
			}
		}

		reset();
		return NODE_STATUS.FAILURE;
	}

	/**
	 * Halts the child if it is running and forgets the failed attempts.
	 */
	override public function halt():Void {
		if (childRunning) {
			super.halt();
		}
		reset();
	}

	private function reset():Void {
		failures = 0;
		childRunning = false;
	}
}
