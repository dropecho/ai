package dropecho.ai.bt.node.decorator;

/**
 * The base for nodes that wrap one child and change its Status.
 */
abstract class DecoratorNode implements Node {
	private var child:Node;
	private var context:Blackboard;

	/**
	 * Creates a decorator around a child.
	 *
	 * @param child - The wrapped node.
	 */
	public function new(child:Node) {
		this.child = child;
	}

	/**
	 * Gives the Blackboard to the child.
	 *
	 * @param context - The Blackboard shared by every node in the tree.
	 */
	public function init(context:Blackboard):Void {
		this.context = context;
		if (this.child.init != null) {
			this.child.init(context);
		}
	}

	/**
	 * Runs the child for one tick and returns its changed Status.
	 *
	 * @return The decorator's Status for this tick.
	 */
	abstract public function execute():NODE_STATUS;
}
