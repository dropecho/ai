package dropecho.ai.bt.node.composite;

/**
 * A composite's position in its children: which child runs next.
 *
 * It is not a Haxe Iterator; it keeps its place between ticks so a running child is resumed.
 */
class ChildCursor {
	private var children:Array<Node>;
	private var index:Int;

	/**
	 * Creates a cursor at the first child. The array is used, not copied.
	 *
	 * @param children - The children, in the order they run.
	 */
	public function new(children:Array<Node>) {
		this.children = children;
		this.index = 0;
	}

	/**
	 * Reads the current child without moving.
	 *
	 * @return The child the cursor is on.
	 */
	public function current():Node {
		return children[index];
	}

	/** Moves the cursor to the next child; call it only when `isOnLast` is false. */
	public function advance():Void {
		index++;
	}

	/**
	 * Says whether the cursor is on the last child, so there is no child to advance to.
	 *
	 * @return True if the current child is the last one.
	 */
	public function isOnLast():Bool {
		return index >= children.length - 1;
	}

	/** Moves the cursor back to the first child. */
	public function reset():Void {
		index = 0;
	}
}
