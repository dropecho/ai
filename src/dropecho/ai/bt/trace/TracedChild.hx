package dropecho.ai.bt.trace;

import dropecho.ai.bt.node.IParentNode;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;

/**
 * How parents run and halt a child so that their tracer, if they have one, hears about it.
 */
class TracedChild {
	/**
	 * Executes `child` and reports its Status to `tracer`.
	 *
	 * @param child - The child to run.
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @param tracer - Told about the run; null for none.
	 * @return The child's Status.
	 */
	public static inline function execute(child:Node, deltaTime:Float, tracer:Null<ITreeTracer>):NODE_STATUS {
		var status = child.execute(deltaTime);
		if (tracer != null) {
			tracer.onTick(child, status, deltaTime);
		}
		return status;
	}

	/**
	 * Reports the halt to `tracer`, then halts `child`.
	 *
	 * @param child - The child to halt.
	 * @param tracer - Told about the halt; null for none.
	 */
	public static inline function halt(child:Node, tracer:Null<ITreeTracer>):Void {
		if (tracer != null) {
			tracer.onHalt(child);
		}
		child.halt();
	}

	/**
	 * Gives `tracer` to every child that is a parent node, which passes it on to its own subtree.
	 *
	 * @param children - The children to pass the tracer to.
	 * @param tracer - The tracer, or null to stop tracing.
	 */
	public static function passOn(children:Array<Node>, tracer:Null<ITreeTracer>):Void {
		for (child in children) {
			var isParent = Std.isOfType(child, IParentNode);
			if (isParent) {
				var parent:IParentNode = cast child;
				parent.setTracer(tracer);
			}
		}
	}
}
