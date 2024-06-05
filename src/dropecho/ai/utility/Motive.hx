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
		// loop through array, and get important motive.
		// this will typically be the lowest one.

		var lowest = motives.fold(function(motive:Motive, result:Motive) {
			if (result != null && result.value < motive.value) {
				return result;
			}
			return motive;
		}, null);

		return lowest;
	}

	public function toString() {
		return Json.stringify(motives, null, "  ");
	}
}
