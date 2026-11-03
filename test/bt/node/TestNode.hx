package bt.node;

import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.Blackboard;

class TestNode implements Node {
	public var executed:Int = 0;
	public var halted:Int = 0;
	public var lastDeltaTime:Float = 0;
	public var context:Blackboard;
	public var execReturn:NODE_STATUS;

	public function new(?execReturn:NODE_STATUS) {
		this.execReturn = execReturn ?? NODE_STATUS.SUCCESS;
	}

	public function init(context:Blackboard) {
		this.context = context;
	}

	public function execute(deltaTime:Float):NODE_STATUS {
		this.executed++;
		this.lastDeltaTime = deltaTime;
		return this.execReturn;
	}

	public function halt():Void {
		this.halted++;
	}
}
