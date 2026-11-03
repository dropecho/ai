package dropecho.ai.bt.node;

/**
 * A Wait: a leaf that is RUNNING until a length of time has passed, then succeeds.
 *
 * Time counts from the tick the wait starts on, using the deltaTime of the ticks after it,
 * so it only advances on ticks the node receives. After succeeding or being halted it starts afresh.
 */
@:expose("bt.WaitNode")
class WaitNode extends LeafNode {
	private var duration:Float;
	private var isWaiting:Bool = false;
	private var elapsed:Float = 0;

	/**
	 * Creates a Wait.
	 *
	 * @param duration - How long to wait, in the game's time unit (the unit it passes as deltaTime); throws unless finite and at least 0.
	 */
	public function new(duration:Float) {
		super();
		this.duration = Duration.check(duration, "WaitNode duration", "new WaitNode(2.5) waits 2.5 time units");
	}

	/**
	 * Advances the wait by one tick.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit; ignored on the tick the wait starts.
	 * @return SUCCESS on the tick the waited time reaches the duration, otherwise RUNNING.
	 */
	public function execute(deltaTime:Float):NODE_STATUS {
		if (isWaiting) {
			elapsed += deltaTime;
		} else {
			isWaiting = true;
		}

		var waitIsOver = elapsed >= duration;
		if (waitIsOver) {
			reset();
			return NODE_STATUS.SUCCESS;
		}

		return NODE_STATUS.RUNNING;
	}

	/**
	 * Forgets the time waited so far, so the next tick starts a new wait.
	 */
	override public function halt():Void {
		reset();
	}

	private function reset():Void {
		isWaiting = false;
		elapsed = 0;
	}
}
