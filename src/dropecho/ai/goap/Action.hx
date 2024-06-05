package dropecho.ai.goap;

import dropecho.interop.AbstractFunc.Action_1;
import dropecho.interop.AbstractFunc.Func_0;

class Action {
	/** This is a test */
	public var ActionType:String;

	/** This is a test */
	public var Cost:Int;

	/** This is a test */
	public var Preconditions:Array<String> = new Array<String>();

	/** This is a test */
	public var Postconditions:Array<String> = new Array<String>();

	/** This is the function called every frame */
	public var UpdateFunc:Action_1<Float>;

	/** This is a test */
	public var PreMatcher:Func_0<Bool> = () -> true;

	/** This is a test */
	public var PostMatcher:Func_0<Bool> = () -> true;

	public function new(
		actionType:String,
		updateFunc:Float->Void,
		cost:Int = 0,
		?preconditions:Array<String>,
		?postconditions:Array<String>,
		?preMatcher:Func_0<Bool>,
		?postMatcher:Func_0<Bool>
	) {
		ActionType = actionType;
		UpdateFunc = updateFunc;
		Cost = cost;
		Preconditions = preconditions ?? Preconditions;
		Postconditions = postconditions ?? Postconditions;
		PreMatcher = preMatcher ?? PreMatcher;
		PostMatcher = postMatcher ?? PostMatcher;
	}

	/** This is a test */
	inline public function preconditions_satisfied():Bool {
		return PreMatcher();
	}

	/** This is a test */
	inline public function postconditions_satisfied():Bool {
		return PostMatcher();
	}

	/**
	 * Run the action, invoking the given update function.
	 *
	 * @param delta_time - The time since the last update. 
	 */
	inline public function update(delta_time:Float):Void {
		UpdateFunc(delta_time);
	}
}
