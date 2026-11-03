package dropecho.ai.bt.node.decorator;

#if js
/**
 * The Abort mode values exposed to JavaScript as `bt.AbortMode`, matching the `AbortMode` enum abstract.
 */
@:expose("bt.AbortMode")
class AbortMode_IMPL {
	/** The Guard asks its Check only when its child is not already running. */
	static public var NONE = 0;
	/** The Guard re-asks its Check every tick while its child runs, and halts the child when it turns false. */
	static public var SELF = 1;
	/** The parent composite re-asks the Guard's Check while a later sibling runs, and restarts at the Guard when it changes in the Guard's favour. */
	static public var LOWER_PRIORITY = 2;
	/** Both SELF and LOWER_PRIORITY. */
	static public var BOTH = 3;
}
#else
/**
 * When a Guard's Check is asked again while something is already running: NONE, SELF, LOWER_PRIORITY or BOTH.
 *
 * Converts to and from `Int` (0 to 3).
 */
@:expose("bt.AbortMode")
#end
enum abstract AbortMode(Int) to Int from Int {
	/** The Guard asks its Check only when its child is not already running. */
	var NONE = 0;
	/** The Guard re-asks its Check every tick while its child runs, and halts the child when it turns false. */
	var SELF = 1;
	/** The parent composite re-asks the Guard's Check while a later sibling runs, and restarts at the Guard when it changes in the Guard's favour. */
	var LOWER_PRIORITY = 2;
	/** Both SELF and LOWER_PRIORITY. */
	var BOTH = 3;
}
