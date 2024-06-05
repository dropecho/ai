package dropecho.ai.goap;

class State {
	public var Relevance(default, null):Int;
	public var Preconditions(default, null):Array<String>;

	public function new(preconditions:Array<String>, relevance:Int = 0) {
		Relevance = relevance;
		Preconditions = preconditions;
	}
}
