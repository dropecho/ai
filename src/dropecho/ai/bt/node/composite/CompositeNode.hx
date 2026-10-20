package dropecho.ai.bt.node.composite;

using Lambda;

/**
 * The base for nodes with several children, run in order; one tick runs on through children until one decides the result or is running.
 *
 * Its child cursor keeps its place between ticks, so a running child is resumed next tick without re-running the children before it.
 */
abstract class CompositeNode implements Node {
	private var children:Array<Node>;
	private var childCursor:ChildCursor;
	private var context:Blackboard;

	/**
	 * Creates a composite whose child cursor starts at the first child.
	 *
	 * @param children - The children, in the order they run; the array is used, not copied.
	 */
	public function new(children:Array<Node>) {
		this.children = children;
		this.childCursor = new ChildCursor(children);
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
	 * Runs children from the current one in the same tick, until a child returns the deciding status, the last child finishes, or a child is running.
	 *
	 * @param decidingStatus - The child Status that ends the composite early: SUCCESS for a Selector, FAILURE for a Sequence.
	 * @return The deciding status, or the last child's Status (both return to the first child), or RUNNING when a child is running (resumed next tick).
	 */
	private function runChildren(decidingStatus:NODE_STATUS):NODE_STATUS {
		while (true) {
			var childStatus = this.childCursor
				.current()
				.execute();

			if (childStatus == NODE_STATUS.RUNNING) {
				return NODE_STATUS.RUNNING;
			}

			var isDecided = childStatus == decidingStatus;
			var isLastChild = this.childCursor.isOnLast();
			if (isDecided || isLastChild) {
				this.childCursor.reset();
				return childStatus;
			}

			this.childCursor.advance();
		}
	}

	/**
	 * Runs children from the current one for this tick and moves the child cursor.
	 *
	 * @return The composite's Status for this tick.
	 */
	abstract public function execute():NODE_STATUS;
}
