package dropecho.ai.bt.node;

import dropecho.ai.Blackboard;
import dropecho.util.NotImplementedException;

/**
 * The base for game-defined leaf nodes written as classes instead of Tasks.
 *
 * Subclasses must override `execute`; they can read the Blackboard from `context`.
 */
@:expose("bt.LeafNode")
class LeafNode implements Node {
	private var context:Blackboard;

	/**
	 * Creates a leaf node; it has no Blackboard until `init` is called.
	 */
	public function new() {}

	/**
	 * Stores the Blackboard for `execute` to use.
	 *
	 * @param context - The Blackboard shared by every node in the tree.
	 */
	public function init(context:Blackboard):Void {
		this.context = context;
	}

	/**
	 * Runs one tick of the leaf; subclasses must override it.
	 *
	 * @return The leaf's Status for this tick.
	 * @throws NotImplementedException If not overridden.
	 */
	public function execute():NODE_STATUS {
		throw new NotImplementedException();
	}
}
