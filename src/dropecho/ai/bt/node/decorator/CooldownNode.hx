package dropecho.ai.bt.node.decorator;

/**
 * A Cooldown: after its child finishes (SUCCESS or FAILURE), fails without running the child until a length of time has passed.
 *
 * Like Unreal's Cooldown, the wait starts when the child finishes. Time only advances on ticks the Cooldown
 * receives, so a branch the tree is not ticking (e.g. behind a RUNNING sibling of a non-reactive composite)
 * stays cooling down; tick it every tick (a reactive composite) if the cooldown must follow game time.
 * Halting stops a running child but keeps an active cooldown, since it limits how often the child runs across runs.
 */
@:expose("bt.CooldownNode")
class CooldownNode extends DecoratorNode {
	private var cooldown:Float;
	private var isCoolingDown:Bool = false;
	private var elapsed:Float = 0;

	/**
	 * Creates a Cooldown.
	 *
	 * @param child - The node limited in how often it runs.
	 * @param cooldown - How long to fail after the child finishes, in the game's time unit (the unit it passes as deltaTime); throws unless finite and at least 0.
	 */
	public function new(child:Node, cooldown:Float) {
		super(child);
		this.cooldown = Duration.check(cooldown, "CooldownNode cooldown", "new CooldownNode(child, 5) waits 5 time units between runs");
	}

	/**
	 * Runs the child once, unless it is cooling down.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit; counts toward an active cooldown.
	 * @return FAILURE while cooling down, otherwise the child's Status.
	 */
	public function execute(deltaTime:Float):NODE_STATUS {
		if (isCoolingDown) {
			elapsed += deltaTime;
			var cooldownIsOver = elapsed >= cooldown;
			if (cooldownIsOver == false) {
				return NODE_STATUS.FAILURE;
			}

			isCoolingDown = false;
		}

		var status = executeChild(deltaTime);
		if (status != NODE_STATUS.RUNNING) {
			isCoolingDown = true;
			elapsed = 0;
		}

		return status;
	}
}
