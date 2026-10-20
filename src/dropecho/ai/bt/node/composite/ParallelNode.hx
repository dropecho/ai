package dropecho.ai.bt.node.composite;

using Lambda;

/**
 * A Parallel: ticks every child each tick and decides by counting how many have succeeded and failed.
 *
 * A child that finished keeps its result for the rest of the run and is not ticked again.
 * When enough children succeed (or fail), the children still RUNNING are halted and the run ends.
 * With no children it succeeds at once.
 */
@:expose("bt.ParallelNode")
class ParallelNode implements Node {
	private var children:Array<Node>;
	private var childResults:Array<Null<NODE_STATUS>>;
	private var successCount:Int = 0;
	private var failureCount:Int = 0;

	/** How many children must succeed for the Parallel to succeed. */
	public var successThreshold(default, null):Int;

	/** How many children must fail for the Parallel to fail. */
	public var failureThreshold(default, null):Int;

	/**
	 * Creates a Parallel; throws if a threshold given is not between 1 and the number of children.
	 *
	 * @param children - The children, ticked in this order each tick; the array is used, not copied.
	 * @param successThreshold - How many children must succeed; defaults to all of them (1 means "any").
	 * @param failureThreshold - How many children must fail; defaults to 1.
	 */
	public function new(children:Array<Node>, ?successThreshold:Int, ?failureThreshold:Int) {
		this.children = children;
		this.childResults = [for (_ in children) null];
		this.successThreshold = successThreshold ?? children.length;
		this.failureThreshold = failureThreshold ?? 1;

		if (successThreshold != null) {
			_validateThreshold("successThreshold", successThreshold);
		}
		if (failureThreshold != null) {
			_validateThreshold("failureThreshold", failureThreshold);
		}
	}

	/**
	 * Gives the Blackboard to every child.
	 *
	 * @param context - The Blackboard shared by every node in the tree.
	 */
	public function init(context:Blackboard):Void {
		function initChild(child) {
			if (child.init != null) {
				child.init(context);
			}
		}

		this.children.iter(initChild);
	}

	/**
	 * Ticks every child that has not finished in this run, stopping as soon as the result is decided.
	 * Failure is decided early when too few children are left unfinished to reach the success threshold.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return SUCCESS or FAILURE once a threshold is reached (running children are halted and the next execute starts afresh), otherwise RUNNING.
	 */
	public function execute(deltaTime:Float):NODE_STATUS {
		for (index in 0...children.length) {
			var isFinished = childResults[index] == NODE_STATUS.SUCCESS || childResults[index] == NODE_STATUS.FAILURE;
			if (isFinished) {
				continue;
			}

			var childStatus = children[index].execute(deltaTime);
			childResults[index] = childStatus;
			if (childStatus == NODE_STATUS.SUCCESS) {
				successCount++;
			} else if (childStatus == NODE_STATUS.FAILURE) {
				failureCount++;
			}

			var decided = _decidedStatus();
			if (decided != null) {
				halt();
				return decided;
			}
		}

		var decided = _decidedStatus();
		if (decided != null) {
			halt();
			return decided;
		}

		return NODE_STATUS.RUNNING;
	}

	/**
	 * Halts every child still RUNNING and forgets the results recorded in this run.
	 */
	public function halt():Void {
		for (index in 0...children.length) {
			if (childResults[index] == NODE_STATUS.RUNNING) {
				children[index].halt();
			}
			childResults[index] = null;
		}
		successCount = 0;
		failureCount = 0;
	}

	private function _decidedStatus():Null<NODE_STATUS> {
		var hasEnoughSuccesses = successCount >= successThreshold;
		var maxFailuresBeforeSuccessIsImpossible = children.length - successThreshold;
		var hasEnoughFailures = failureCount >= failureThreshold || failureCount > maxFailuresBeforeSuccessIsImpossible;

		if (hasEnoughSuccesses) {
			return NODE_STATUS.SUCCESS;
		}
		if (hasEnoughFailures) {
			return NODE_STATUS.FAILURE;
		}
		return null;
	}

	private function _validateThreshold(name:String, threshold:Int):Void {
		var isInRange = threshold >= 1 && threshold <= children.length;
		if (isInRange == false) {
			throw 'ParallelNode $name must be between 1 and the number of children (${children.length}), but got $threshold. '
				+ 'A threshold above the child count can never be reached; leave it out to use the default.';
		}
	}
}
