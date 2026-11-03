package dropecho.ai.fsm;

/** A game-defined State an agent can be in, with enter, exit and per-tick behaviour. */
@:expose("fsm.State")
@:nativeChildren
interface IState {
	/**
	 * Names the State, for display such as the State graph. Transitions belong to the State object, so names need not be unique.
	 *
	 * @return The State's name.
	 */
	public function getName():String;

	/** Called when the state machine changes to this State. */
	public function onEnter():Void;

	/** Called when the state machine leaves this State. */
	public function onExit():Void;

	/** Called on each state machine tick while this State is current, before Conditions are checked. */
	public function tick():Void;
}
