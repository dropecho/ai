package dropecho.ai;

import dropecho.interop.AbstractMap;

@:expose("Blackboard")
class Blackboard {
	var _facts = new AbstractMap<String, Int>();

	public function new() {}

	inline public function get(key:String):Int {
		return _facts.exists(key) ? _facts.get(key) : 0;
	}

	inline public function set(key:String, value:Int):Int {
		return _facts.set(key, value);
	}

	inline public function increment(key:String):Int {
		return _facts.set(key, _facts.get(key) + 1);
	}

	inline public function decrement(key:String):Int {
		return _facts.set(key, _facts.get(key) - 1);
	}
}
