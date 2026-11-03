package dropecho.ai.bt.node;

import dropecho.ai.Blackboard;

/**
 * The base for game-defined leaf nodes written as classes instead of Tasks.
 *
 * Subclasses implement `execute` (without `override`); they can read the Blackboard from `context`.
 */
@:expose("bt.LeafNode")
abstract class LeafNode implements Node {
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
	 * Called when the leaf was running and its parent abandons it; does nothing unless overridden.
	 * Override it to stop work in progress (a move, an animation) and clear per-run state.
	 */
	public function halt():Void {}

	/**
	 * Runs one tick of the leaf.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return The leaf's Status for this tick.
	 */
	abstract public function execute(deltaTime:Float):NODE_STATUS;
}
