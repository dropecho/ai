package dropecho.ai;

import dropecho.interop.AbstractMap;

@:expose("Blackboard")
class Blackboard {
	public var facts = new AbstractMap<String, Float>();

	public function new() {}

	public function get(key:String):Float {
		return facts.exists(key) ? facts.get(key) : 0;
	}

	public function set(key:String, value:Float):Float {
		return facts.set(key, value);
	}

	public function increment(key:String):Float {
		return facts.set(key, facts.get(key) + 1);
	}

	public function decrement(key:String):Float {
		return facts.set(key, facts.get(key) - 1);
	}
}
