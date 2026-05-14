package dropecho.ai.utility;

import haxe.Json;

using Lambda;

class Motive {
	public var name:String;
	public var value:Float;

	public function new(name:String, value:Float) {
		this.name = name;
		this.value = value;
	}
}

class UtilityAgent {
	public var motives:Array<Motive> = new Array<Motive>();

	public function new() {}

	public function getMostImportantMotive() {
		return motives.fold(foldToLowestMotive, null);
	}

	inline private function foldToLowestMotive(motive:Motive, result:Motive):Motive {
		if (result?.value < motive.value) {
			return result;
		}
		return motive;
	}

	inline public function toString() {
		return Json.stringify(motives, null, "  ");
	}
}
