package dropecho.ai.bt.node;

import dropecho.ai.bt.trace.ITreeTracer;

/**
 * A node with children (a Composite, Parallel, Decorator or whole tree): it can list them and report on them to a tracer.
 */
@:expose("bt.IParentNode")
interface IParentNode {
	/**
	 * Lists the children, in the order they run.
	 *
	 * @return A copy of the children; changing it does not change the node.
	 */
	public function children():Array<Node>;

	/**
	 * Makes this node and every parent below it report each child they execute or halt to `tracer`.
	 *
	 * @param tracer - The tracer, or null to stop tracing.
	 */
	public function setTracer(tracer:Null<ITreeTracer>):Void;
}
