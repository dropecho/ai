package dropecho.ai.bt.node.decorator;

/**
 * A Timeout: fails, halting its child, if the child is still RUNNING after a time limit.
 *
 * Time counts from the tick a run starts on, using the deltaTime of the ticks after it.
 * The child is ticked while the time used is at most the limit, so a child needing exactly the limit finishes.
 * Each run (until the child finishes, the time runs out or the Timeout is halted) gets the full limit.
 */
@:expose("bt.TimeoutNode")
class TimeoutNode extends DecoratorNode {
	private var limit:Float;
	private var isTiming:Bool = false;
	private var elapsed:Float = 0;

	/**
	 * Creates a Timeout.
	 *
	 * @param child - The node given a limited time to finish.
	 * @param limit - The time the child may run, in the game's time unit (the unit it passes as deltaTime); throws unless finite and at least 0.
	 */
	public function new(child:Node, limit:Float) {
		super(child);
		this.limit = Duration.check(limit, "TimeoutNode limit", "new TimeoutNode(child, 3) gives the child 3 time units");
	}

	/**
	 * Runs the child once, unless its time has run out.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit; ignored on the tick a run starts.
	 * @return The child's Status, or FAILURE (after halting the child) once the time used exceeds the limit.
	 */
	public function execute(deltaTime:Float):NODE_STATUS {
		if (isTiming) {
			elapsed += deltaTime;
			var timeIsUp = elapsed > limit;
			if (timeIsUp) {
				child.halt();
				reset();
				return NODE_STATUS.FAILURE;
			}
		} else {
			isTiming = true;
		}

		var status = child.execute(deltaTime);
		if (status != NODE_STATUS.RUNNING) {
			reset();
		}

		return status;
	}

	/**
	 * Halts the child and forgets the time used, so the next run gets the full limit.
	 */
	override public function halt():Void {
		reset();
		super.halt();
	}

	private function reset():Void {
		isTiming = false;
		elapsed = 0;
	}
}
