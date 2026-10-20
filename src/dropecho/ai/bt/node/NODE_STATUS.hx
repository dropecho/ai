package dropecho.ai.bt.node;

#if js
/**
 * The Status values exposed to JavaScript as `bt.NODE_STATUS`, matching the `NODE_STATUS` enum abstract.
 */
@:expose("bt.NODE_STATUS")
class NODE_STATUS_IMPL {
	/** The node finished and succeeded. */
	static public var SUCCESS = 0;
	/** The node finished and failed. */
	static public var FAILURE = 1;
	/** The node has not finished; execute it again next tick. */
	static public var RUNNING = 2;
}
#else
/**
 * A node's Status for one tick: SUCCESS, FAILURE or RUNNING.
 *
 * Converts to and from `Int` (0, 1 and 2).
 */
@:expose("bt.NODE_STATUS")
#end
enum abstract NODE_STATUS(Int) to Int from Int {
	/** The node finished and succeeded. */
	var SUCCESS = 0;
	/** The node finished and failed. */
	var FAILURE = 1;
	/** The node has not finished; execute it again next tick. */
	var RUNNING = 2;
}
