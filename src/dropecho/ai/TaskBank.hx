package dropecho.ai;

import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.interop.AbstractMap;

typedef Task = Blackboard->NODE_STATUS;
typedef TaskMap = AbstractMap<String, Task>;

@:expose("TaskBank")
class TaskBank {
	private static var tasks:TaskMap = new TaskMap();

	inline public static function register(name:String, task:Task):Void {
		tasks.set(name, task);
	}

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
