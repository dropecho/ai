package dropecho.ai;

import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.interop.AbstractMap;

/** A game-defined function that does a leaf's work: it gets the Blackboard and returns a Status. */
typedef Task = Blackboard->NODE_STATUS;
/** Tasks keyed by name. */
typedef TaskMap = AbstractMap<String, Task>;

/** The Task registry: game code registers Tasks by name so behavior trees can refer to them by name. It is global (static). */
@:expose("TaskBank")
class TaskBank {
	private static var tasks:TaskMap = new TaskMap();

	/**
	 * Registers a Task under `name`, replacing any Task already registered with that name.
	 *
	 * @param name - The name trees use to refer to the Task.
	 * @param task - The Task.
	 */
	inline public static function register(name:String, task:Task):Void {
		tasks.set(name, task);
	}

	/**
	 * Looks up a registered Task.
	 * Throws a message listing the registered names if `name` is not registered.
	 *
	 * @param name - The Task's name.
	 * @return The Task registered under `name`.
	 */
	public static function get(name:String):Task {
		var isRegistered = tasks.exists(name);
		if (isRegistered == false) {
			throw unknownTaskMessage(name);
		}

		return tasks.get(name);
	}

	private static function unknownTaskMessage(name:String):String {
		var registeredNames = [for (registeredName in tasks.keys()) registeredName];
		registeredNames.sort(Reflect.compare);
		var registeredList = registeredNames.length == 0 ? "(none)" : registeredNames.join(", ");

		return 'Unknown task "$name". Registered tasks: $registeredList.\n'
			+ 'Register it first with: TaskBank.register("$name", context -> NODE_STATUS.SUCCESS)';
	}
}
