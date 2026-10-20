package dropecho.ai.bt.node.composite;

using Lambda;

/**
 * The base for nodes with several children, run in order; one tick runs on through children until one decides the result or is running.
 *
 * Its child cursor keeps its place between ticks, so a running child is resumed next tick without re-running the children before it.
 * A reactive composite instead starts from its first child every tick, so a higher-priority child can take over from a running one;
 * the child it no longer reaches is halted. A non-reactive composite gets the same take-over only from earlier children that ask for it
 * (`IAbortsLowerPriority`, such as a Guard with LOWER_PRIORITY).
 */
abstract class CompositeNode implements Node {
	private var children:Array<Node>;
	private var childCursor:ChildCursor;
	private var context:Blackboard;
	private var runningChild:Null<Node> = null;

	/** When true, every tick starts again from the first child instead of resuming a running one. */
	public var reactive:Bool;

	/**
	 * Creates a composite whose child cursor starts at the first child.
	 *
	 * @param children - The children, in the order they run; the array is used, not copied.
	 * @param reactive - Start from the first child every tick; defaults to false.
	 */
	public function new(children:Array<Node>, reactive:Bool = false) {
		this.children = children;
		this.childCursor = new ChildCursor(children);
		this.reactive = reactive;
	}

	/**
	 * Gives the Blackboard to every child.
	 *
	 * @param context - The Blackboard shared by every node in the tree.
	 */
	public function init(context:Blackboard):Void {
		this.context = context;

		function initChild(child) {
			if (child.init != null) {
				child.init(context);
			}
		}

		this.children.iter(initChild);
	}

	/**
	 * Runs children from the current one (the first one, when reactive) in the same tick, until a child returns the deciding status,
	 * the last child finishes, or a child is running.
	 *
	 * A child that was running on an earlier tick and is not reached again (a reactive restart decided first, or a different child is
	 * now running) is halted. A non-reactive composite first lets an earlier Guard with LOWER_PRIORITY abort the running child.
	 *
	 * @param decidingStatus - The child Status that ends the composite early: SUCCESS for a Selector, FAILURE for a Sequence.
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return The deciding status, or the last child's Status (both return to the first child), or RUNNING when a child is running (resumed next tick).
	 */
	private function runChildren(decidingStatus:NODE_STATUS, deltaTime:Float):NODE_STATUS {
		if (reactive) {
			this.childCursor.reset();
		} else {
			_abortLowerPriorityIfAsked(decidingStatus);
		}

		while (true) {
			var child = this.childCursor.current();
			var childStatus = child.execute(deltaTime);

			if (childStatus == NODE_STATUS.RUNNING) {
				_haltRunningChildUnless(child);
				runningChild = child;
				return NODE_STATUS.RUNNING;
			}

			if (child == runningChild) {
				runningChild = null;
			}

			var isDecided = childStatus == decidingStatus;
			var isLastChild = this.childCursor.isOnLast();
			if (isDecided || isLastChild) {
				_haltRunningChildUnless(null);
				this.childCursor.reset();
				return childStatus;
			}

			this.childCursor.advance();
		}
	}

	/**
	 * Halts the running child, if any, and returns to the first child.
	 */
	public function halt():Void {
		_haltRunningChildUnless(null);
		this.childCursor.reset();
	}

	/**
	 * While a child is running, asks each earlier child that can abort lower priority (a Guard with LOWER_PRIORITY) whether it
	 * wants to; the first that does has the running child halted and the child cursor moved back to it.
	 *
	 * @param decidingStatus - The child Status that ends the composite early: SUCCESS for a Selector, FAILURE for a Sequence.
	 */
	private function _abortLowerPriorityIfAsked(decidingStatus:NODE_STATUS):Void {
		if (runningChild == null) {
			return;
		}

		for (index in 0...children.length) {
			var child = children[index];
			if (child == runningChild) {
				return;
			}

			var canAbortLowerPriority = Std.isOfType(child, IAbortsLowerPriority);
			if (canAbortLowerPriority) {
				var observer:IAbortsLowerPriority = cast child;
				if (observer.wantsToAbortLowerPriority(decidingStatus)) {
					_haltRunningChildUnless(null);
					_moveCursorTo(index);
					return;
				}
			}
		}
	}

	private function _moveCursorTo(index:Int):Void {
		this.childCursor.reset();
		for (_ in 0...index) {
			this.childCursor.advance();
		}
	}

	private function _haltRunningChildUnless(stillRunning:Null<Node>):Void {
		var isAbandoned = runningChild != null && runningChild != stillRunning;
		if (isAbandoned) {
			runningChild.halt();
		}
		runningChild = null;
	}

	/**
	 * Runs children from the current one for this tick and moves the child cursor.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return The composite's Status for this tick.
	 */
	abstract public function execute(deltaTime:Float):NODE_STATUS;
}
