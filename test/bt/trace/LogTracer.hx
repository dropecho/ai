package bt.trace;

import haxe.ds.ObjectMap;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.bt.trace.ITreeTracer;

class LogTracer implements ITreeTracer {
	public var events:Array<String> = [];

	private var names = new ObjectMap<Node, String>();

	public function new() {}

	public function name<T:Node>(node:T, name:String):T {
		names.set(node, name);
		return node;
	}

	public function onTick(node:Node, status:NODE_STATUS, deltaTime:Float):Void {
		events.push('tick ${nameOf(node)} ${statusName(status)}');
	}

	public function onHalt(node:Node):Void {
		events.push('halt ${nameOf(node)}');
	}

	private function nameOf(node:Node):String {
		return names.exists(node) ? names.get(node) : "?";
	}

	private function statusName(status:NODE_STATUS):String {
		return switch (status) {
			case NODE_STATUS.SUCCESS: "SUCCESS";
			case NODE_STATUS.FAILURE: "FAILURE";
			case NODE_STATUS.RUNNING: "RUNNING";
			case _: "?";
		}
	}
}
