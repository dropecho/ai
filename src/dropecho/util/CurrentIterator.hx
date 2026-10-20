package dropecho.util;

/** A cursor over an array that can also report its current item without moving; composites use it as their child cursor. */
class CurrentIterator<T> {
	private var array:Array<T>;
	private var i:Int;

	/**
	 * Creates a cursor at the first item. The array is not copied.
	 *
	 * @param array - The items to step through.
	 */
	public function new(array:Array<T>) {
		this.array = array;
		this.i = 0;
	}

	/**
	 * Returns the current item, then moves to the next one.
	 *
	 * @return The item that was current.
	 */
	public function next():T {
		return array[i++];
	}

	/**
	 * Says whether there is an item after the current one (not whether the current one exists).
	 *
	 * @return True if the cursor is before the last item.
	 */
	public function hasNext():Bool {
		return i < array.length - 1;
	}

	/**
	 * Reads the current item without moving.
	 *
	 * @return The current item.
	 */
	public function current():T {
		return array[i];
	}

	/** Moves the cursor back to the first item. */
	public function reset():Void {
		this.i = 0;
	}
}
