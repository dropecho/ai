package dropecho.ai.bt.node.decorator;

import dropecho.ai.bt.trace.ITreeTracer;
import dropecho.ai.bt.trace.TracedChild;

/**
 * The base for nodes that wrap one child and change its Status.
 *
 * Subclasses run and halt the child with `executeChild` and `haltChild`, so a tracer hears about it.
 */
abstract class DecoratorNode implements Node implements IParentNode {
	private var child:Node;
	private var context:Blackboard;
	private var tracer:Null<ITreeTracer> = null;

	/**
	 * Creates a decorator around a child.
	 *
	 * @param child - The wrapped node.
	 */
	public function new(child:Node) {
		this.child = child;
	}

	/**
	 * Gives the Blackboard to the child.
	 *
	 * @param context - The Blackboard shared by every node in the tree.
	 */
	public function init(context:Blackboard):Void {
		this.context = context;
		if (this.child.init != null) {
			this.child.init(context);
		}
	}

	/**
	 * Lists the wrapped child.
	 *
	 * @return A new array holding the child.
	 */
	public function children():Array<Node> {
		return [this.child];
	}

	/**
	 * Reports every run and halt of the child to `tracer`, and passes it on to the parents below.
	 *
	 * @param tracer - The tracer, or null to stop tracing.
	 */
	public function setTracer(tracer:Null<ITreeTracer>):Void {
		this.tracer = tracer;
		TracedChild.passOn([this.child], tracer);
	}

	/**
	 * Halts the child; decorators that keep per-run state override this and call `super.halt()`.
	 */
	public function halt():Void {
		haltChild();
	}

	/**
	 * Executes the child once and reports it to the tracer.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return The child's Status.
	 */
	private function executeChild(deltaTime:Float):NODE_STATUS {
		return TracedChild.execute(this.child, deltaTime, tracer);
	}

	/** Reports the halt to the tracer, then halts the child. */
	private function haltChild():Void {
		TracedChild.halt(this.child, tracer);
	}

	/**
	 * Runs the child for one tick and returns its changed Status.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return The decorator's Status for this tick.
	 */
	abstract public function execute(deltaTime:Float):NODE_STATUS;
}
