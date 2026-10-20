package dropecho.ai.bt.node;

import dropecho.ai.TaskBank;
import dropecho.ai.Blackboard;

/**
 * A leaf node that runs a Task from the Task registry (`TaskBank`) each tick.
 */
@:expose("bt.TaskNode")
class TaskNode implements Node {
	private var action:Task;
	private var context:Blackboard;

	/**
	 * Creates a node for a registered Task, looked up now rather than at tick time.
	 *
	 * @param taskName - The name the Task was registered under; throws if no Task has that name.
	 */
	public function new(taskName:String) {
		action = TaskBank.get(taskName);
	}

	/**
	 * Stores the Blackboard that the Task is given each tick.
	 *
	 * @param context - The Blackboard shared by every node in the tree.
	 */
	public function init(context:Blackboard):Void {
		this.context = context;
	}

	/**
	 * Runs the Task once with the Blackboard.
	 *
	 * @return The Task's Status for this tick.
	 */
	public function execute():NODE_STATUS {
		return action(this.context);
	};
}
