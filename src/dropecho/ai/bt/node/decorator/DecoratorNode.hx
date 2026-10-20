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
	 * Halts the child; decorators that keep per-run state override this and call `super.halt()`.
	 */
	public function halt():Void {
		this.child.halt();
	}

	/**
	 * Runs the child for one tick and returns its changed Status.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return The decorator's Status for this tick.
	 */
	abstract public function execute(deltaTime:Float):NODE_STATUS;
}
