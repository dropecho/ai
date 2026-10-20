package dropecho.ai.bt.node;

import dropecho.ai.Blackboard;
import dropecho.ai.bt.node.NODE_STATUS;

/**
 * Something given a Blackboard once, then executed every tick for a result of type `T`.
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
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return The result for this tick.
	 */
	public function execute(deltaTime:Float):T;
}

/**
 * One step of a behavior tree, executed each tick and answering with a Status.
 * A node that returned RUNNING and is then abandoned by its parent is told so with `halt`.
 */
@:expose("bt.Node")
interface Node extends IExecutable<NODE_STATUS> {
	/**
	 * Stops the node because its parent will not tick it again for now: it should clear any
	 * per-run state (positions in children, timers, counts) and halt any running children.
	 * Called only on a node that last returned RUNNING; the next `execute` starts it afresh.
	 */
	public function halt():Void;
}
