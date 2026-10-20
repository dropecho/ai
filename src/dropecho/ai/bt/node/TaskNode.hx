package dropecho.ai.bt.node;

import dropecho.ai.TaskBank;
import dropecho.ai.Blackboard;

/**
 * A leaf node that runs a Task from the Task registry (`TaskBank`) each tick; tree dumps label it with the Task name.
 */
@:expose("bt.TaskNode")
class TaskNode implements Node implements ILabeled {
	private var taskName:String;
	private var action:Task;
	private var context:Blackboard;

	/**
	 * Creates a node for a registered Task, looked up now rather than at tick time.
	 *
	 * @param taskName - The name the Task was registered under; throws if no Task has that name.
	 */
	public function new(taskName:String) {
		this.taskName = taskName;
		action = TaskBank.get(taskName);
	}

	/**
	 * Gives the Task name, which labels this node in tree dumps.
	 *
	 * @return The name the Task was registered under.
	 */
	public function getLabel():Null<String> {
		return taskName;
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
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return The Task's Status for this tick.
	 */
	public function execute(deltaTime:Float):NODE_STATUS {
		return action(this.context, deltaTime);
	};

	/**
	 * Does nothing: a Task is a function with no state of its own. Use a LeafNode subclass for work that must be stopped.
	 */
	public function halt():Void {}
}
