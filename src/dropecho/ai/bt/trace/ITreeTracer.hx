package dropecho.ai.bt.trace;

import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;

/**
 * Watches a behavior tree run: told about every node that is executed or halted.
 *
 * Give it to a tree with `BehaviorTree.setTracer`. Parents report for their children, so leaves and game-defined nodes need no changes.
 * From JavaScript, any object with `onTick` and `onHalt` methods works.
 */
@:expose("bt.ITreeTracer")
interface ITreeTracer {
	/**
	 * Called after a node returns from `execute`, so children are reported before their parent.
	 * A Repeater or Retry may report its child several times in one tick.
	 *
	 * @param node - The node that ran.
	 * @param status - The Status it returned.
	 * @param deltaTime - The delta time it was given.
	 */
	public function onTick(node:Node, status:NODE_STATUS, deltaTime:Float):Void;

	/**
	 * Called when a node is halted, before its own `halt` runs, so a halted subtree is reported from the top down.
	 *
	 * @param node - The node being halted.
	 */
	public function onHalt(node:Node):Void;
}
