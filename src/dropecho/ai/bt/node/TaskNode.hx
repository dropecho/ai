package dropecho.ai.bt.node;

import dropecho.ai.TaskBank;
import dropecho.ai.Blackboard;

/**
 * A leaf node that runs a Task each tick: one given directly, or one looked up by name in the Task registry (`TaskBank`).
 * Tree dumps label it with the Task name.
 */
@:expose("bt.TaskNode")
class TaskNode implements Node implements ILabeled {
	private var taskName:Null<String>;
	private var action:Task;
	private var context:Blackboard;

	/**
	 * Creates a node for a Task. Without `task`, the Task registered under `taskName` is looked up now rather than at tick time.
	 *
	 * @param taskName - With `task`, only the label shown in tree dumps (may be null); without it, the name the Task was
	 *   registered under, and the constructor throws if no Task has that name.
	 * @param task - The Task to run, used instead of the registry.
	 */
	public function new(taskName:Null<String>, ?task:Task) {
		this.taskName = taskName;
		action = task != null ? task : TaskBank.get(taskName);
	}

	/**
	 * Gives the Task name, which labels this node in tree dumps.
	 *
	 * @return The Task name, or null for a Task given directly without one.
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
