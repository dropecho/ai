package dropecho.ai.bt.node;

/**
 * A node with a readable name of its own, shown in tree dumps; a Task node is labelled with its Task name.
 */
@:expose("bt.ILabeled")
interface ILabeled {
	/**
	 * Gives the node's own label.
	 *
	 * @return The label, or null for none.
	 */
	public function getLabel():Null<String>;
}
