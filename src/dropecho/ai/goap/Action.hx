package dropecho.ai.goap;

import dropecho.interop.AbstractFunc.Action_1;
import dropecho.interop.AbstractFunc.Func_0;

class Action {
	public var ActionType:String;
	public var Cost:Int;
	public var Preconditions:Array<String>;
	public var Postconditions:Array<String>;
	public var UpdateFunc:Action_1<Float>;
	public var PreMatcher:Func_0<Bool>;
	public var PostMatcher:Func_0<Bool>;

	public function new(
    actionType:String, 
    updateFunc:Float->Void, 
    cost:Int = 0, 
    ?preconditions:Array<String>, 
    ?postconditions:Array<String>,
		?preMatcher:Func_0<Bool>, 
    ?postMatcher:Func_0<Bool>) 
  {
		ActionType = actionType;
		UpdateFunc = updateFunc;
		Cost = cost;
		Preconditions = preconditions != null ? preconditions : new Array<String>();
		Postconditions = postconditions != null ? postconditions : new Array<String>();
		PreMatcher = preMatcher != null ? preMatcher : () -> true;
		PostMatcher = postMatcher != null ? postMatcher : () -> true;
	}

	public function preconditions_satisfied():Bool {
		return PreMatcher.call();
	}

	public function postconditions_satisfied():Bool {
		return PostMatcher.call();
	}

	public function update(delta_time:Float):Void {
		UpdateFunc.call(delta_time);
	}
}
