package dropecho.ai.bt.node.composite;

/**
 * A child that can ask its non-reactive parent composite to abandon a later, lower-priority running sibling and restart at this child.
 */
interface IAbortsLowerPriority {
	/**
	 * Asked by the parent at the start of each tick while a later sibling is RUNNING.
	 *
	 * @param decidingStatus - The parent's deciding Status: SUCCESS for a Selector, FAILURE for a Sequence.
	 * @return True if the parent should halt the running sibling and run again from this child.
	 */
	public function wantsToAbortLowerPriority(decidingStatus:NODE_STATUS):Bool;
}
