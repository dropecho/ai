package dropecho.ai.bt;

import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;

/**
 * A behavior tree: a root node run once per tick, whose Status is the tree's Status.
 *
 * Call `init` once before the first `execute`.
 */
@:expose("bt.BehaviorTree")
class BehaviorTree implements Node {
	private var child:Node;
	private var context:Blackboard;

	/**
	 * Creates a tree around a root node.
	 *
	 * @param root - The root node, usually a Composite; throws if null.
	 */
	public function new(root:Node) {
		var isMissingRoot = root == null;
		if (isMissingRoot) {
			throw "BehaviorTree needs a root node, but got null. Pass the node to run each tick, e.g. new BehaviorTree(new SequenceNode([...])).";
		}

		this.child = root;
	}

	/**
	 * Gives the Blackboard to every node in the tree.
	 *
	 * @param context - The Blackboard the nodes read and write; a new empty one is used if null.
	 */
	public function init(context:Blackboard):Void {
		if (context == null) {
			context = new Blackboard();
		}

		this.context = context;
		child.init(this.context);
	}

	/**
	 * Runs one tick of the tree from its root.
	 *
	 * @return The root's Status for this tick; RUNNING means call again next tick.
	 */
	public function execute():NODE_STATUS {
		return this.child.execute();
	}
}
