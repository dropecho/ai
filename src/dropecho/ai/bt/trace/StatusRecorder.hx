package dropecho.ai.bt.trace;

import haxe.ds.ObjectMap;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;

/**
 * A tracer that remembers each node's last Status and whether it was halted, for tree dumps and debug views.
 *
 * Call `clear` before a tick to see only what that tick did.
 */
@:expose("bt.StatusRecorder")
class StatusRecorder implements ITreeTracer {
	private var statuses = new ObjectMap<Node, NODE_STATUS>();
	private var halted = new ObjectMap<Node, Bool>();

	/** Creates a recorder that has seen nothing yet. */
	public function new() {}

	/**
	 * Records the Status a node returned.
	 *
	 * @param node - The node that ran.
	 * @param status - The Status it returned.
	 * @param deltaTime - The delta time it was given; unused.
	 */
	public function onTick(node:Node, status:NODE_STATUS, deltaTime:Float):Void {
		statuses.set(node, status);
	}

	/**
	 * Records that a node was halted.
	 *
	 * @param node - The node being halted.
	 */
	public function onHalt(node:Node):Void {
		halted.set(node, true);
	}

	/**
	 * Gives the last Status a node returned since the last `clear`.
	 *
	 * @param node - The node asked about.
	 * @return Its last Status, or null if it has not run.
	 */
	public function statusOf(node:Node):Null<NODE_STATUS> {
		return statuses.get(node);
	}

	/**
	 * Says whether a node was halted since the last `clear`.
	 *
	 * @param node - The node asked about.
	 * @return True if it was halted.
	 */
	public function wasHalted(node:Node):Bool {
		return halted.exists(node);
	}

	/** Forgets every Status and halt recorded so far, e.g. before the next tick. */
	public function clear():Void {
		statuses.clear();
		halted.clear();
	}
}
