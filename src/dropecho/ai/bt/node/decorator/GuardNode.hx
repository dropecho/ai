package dropecho.ai.bt.node.decorator;

import dropecho.ai.bt.node.Check;
import dropecho.ai.bt.node.composite.IAbortsLowerPriority;

/**
 * A Guard (precondition): runs its child only while a Check is true.
 *
 * Its Abort mode says when the Check is asked again while something is already running: SELF re-asks it every tick while the
 * child runs and halts the child when it turns false; LOWER_PRIORITY lets a non-reactive parent re-ask it while a later sibling
 * runs, and abandon that sibling when the Check changes in the Guard's favour.
 */
@:expose("bt.GuardNode")
class GuardNode extends DecoratorNode implements IAbortsLowerPriority {
	private var check:Check;
	private var abortsSelf:Bool;
	private var abortsLowerPriority:Bool;
	private var isChildRunning:Bool = false;
	private var lastCheckResult:Bool = false;

	/**
	 * Creates a Guard.
	 *
	 * @param check - The precondition, given the Blackboard.
	 * @param child - The node run while the Check is true.
	 * @param abort - When the Check is asked again while something is running; defaults to SELF.
	 */
	public function new(check:Check, child:Node, ?abort:AbortMode) {
		super(child);
		this.check = check;

		var mode = abort ?? AbortMode.SELF;
		this.abortsSelf = mode == AbortMode.SELF || mode == AbortMode.BOTH;
		this.abortsLowerPriority = mode == AbortMode.LOWER_PRIORITY || mode == AbortMode.BOTH;
	}

	/**
	 * Asks the Check (unless the child is running and the Abort mode has no SELF), then runs the child if it is true.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return FAILURE if the Check is false (a running child is halted), otherwise the child's Status.
	 */
	public function execute(deltaTime:Float):NODE_STATUS {
		var shouldAsk = isChildRunning == false || abortsSelf;
		if (shouldAsk) {
			lastCheckResult = check(this.context);
			if (lastCheckResult == false) {
				halt();
				return NODE_STATUS.FAILURE;
			}
		}

		var status = this.child.execute(deltaTime);
		isChildRunning = status == NODE_STATUS.RUNNING;
		return status;
	}

	/**
	 * Halts the child if it is running.
	 */
	override public function halt():Void {
		if (isChildRunning) {
			super.halt();
		}
		isChildRunning = false;
	}

	/**
	 * Re-asks the Check when the Abort mode has LOWER_PRIORITY. It wants to abort only when the answer changed since it was last
	 * asked, in the direction that changes the parent's outcome: to true under a Selector, to false under a Sequence.
	 *
	 * @param decidingStatus - The parent's deciding Status: SUCCESS for a Selector, FAILURE for a Sequence.
	 * @return True if the parent should halt its running child and run again from this Guard.
	 */
	public function wantsToAbortLowerPriority(decidingStatus:NODE_STATUS):Bool {
		if (abortsLowerPriority == false) {
			return false;
		}

		var isAllowed = check(this.context);
		var hasChanged = isAllowed != lastCheckResult;
		lastCheckResult = isAllowed;

		var isUnderSelector = decidingStatus == NODE_STATUS.SUCCESS;
		var changesParentOutcome = isUnderSelector ? isAllowed : isAllowed == false;
		return hasChanged && changesParentOutcome;
	}
}
