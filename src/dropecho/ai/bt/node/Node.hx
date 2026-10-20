package dropecho.ai.bt.node;

import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.NODE_STATUS;

/**
 * Something given a Blackboard once, then executed repeatedly for a result of type `T`.
 */
interface IExecutable<T> {
	/**
	 * Gives the Blackboard to this and anything it runs; called once before the first `execute`.
	 *
	 * @param context - The Blackboard to read and write.
	 */
	public function init(context:Blackboard):Void;
	/**
	 * Runs one tick.
	 *
	 * @return The result for this tick.
	 */
	public function execute():T;
}

/**
 * One step of a behavior tree, executed each tick and answering with a Status.
 */
@:expose("bt.Node")
interface Node extends IExecutable<NODE_STATUS> {}
