package dropecho.util;

/** Thrown by code that is declared but not written yet. */
class NotImplementedException extends haxe.Exception {
	/** Creates the exception with the message "Not Implemented.". */
	public function new() {
		super("Not Implemented.");
	}
}
