package dropecho.ai.bt.node.composite;

using Lambda;

import dropecho.util.CurrentIterator;

/**
 * The base for nodes with several children, run in order, one child per tick.
 *
 * Its child cursor keeps its place between ticks, so the next tick resumes at the child it reached.
 */
abstract class CompositeNode implements Node {
	private var children:Array<Node>;
	private var childIterator:CurrentIterator<Node>;
	private var context:Blackboard;

	/**
	 * Creates a composite whose child cursor starts at the first child.
	 *
	 * @param children - The children, in the order they run; the array is used, not copied.
	 */
	public function new(children:Array<Node>) {
		this.children = children;
		this.childIterator = new CurrentIterator(children);
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
	 * Runs the current child for one tick and moves the child cursor.
	 *
	 * @return The composite's Status for this tick.
	 */
	abstract public function execute():NODE_STATUS;
}
