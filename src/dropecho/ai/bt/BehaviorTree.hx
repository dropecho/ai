package dropecho.ai.bt;

import haxe.ds.ObjectMap;
import dropecho.ai.bt.node.ILabeled;
import dropecho.ai.bt.node.IParentNode;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.bt.trace.ITreeTracer;
import dropecho.ai.bt.trace.StatusRecorder;
import dropecho.ai.bt.trace.TracedChild;
import dropecho.ai.bt.trace.TreeDump;

/**
 * A behavior tree: a root node run once per tick, whose Status is the tree's Status.
 *
 * Call `init` once before the first `execute`. `setTracer` reports every node run or halted; `toText` and `toDot` write the tree out.
 */
@:expose("bt.BehaviorTree")
class BehaviorTree implements Node implements IParentNode {
	private var child:Node;
	private var context:Blackboard;
	private var tracer:Null<ITreeTracer> = null;
	private var labels = new ObjectMap<Node, String>();

	/**
	 * Creates a tree around a root node.
	 *
	 * @param root - The root node, usually a Composite; throws if null.
	 */
	public function new(root:Node) {
		var isMissingRoot = root == null;
		if (isMissingRoot) {
			throw "BehaviorTree needs a root node, but got null. Pass the node to run each tick, e.g. new BehaviorTree(new SequenceNode([...])).";
		}

		this.child = root;
	}

	/**
	 * Gives the Blackboard to every node in the tree.
	 *
	 * @param context - The Blackboard the nodes read and write; a new empty one is used if null.
	 */
	public function init(context:Blackboard):Void {
		if (context == null) {
			context = new Blackboard();
		}

		this.context = context;
		child.init(this.context);
	}

	/**
	 * Runs one tick of the tree from its root.
	 *
	 * @param deltaTime - The time since the last tick, in the game's time unit.
	 * @return The root's Status for this tick; RUNNING means call again next tick.
	 */
	public function execute(deltaTime:Float):NODE_STATUS {
		return TracedChild.execute(this.child, deltaTime, tracer);
	}

	/**
	 * Halts the root, for example when the game stops running this tree while it is RUNNING.
	 */
	public function halt():Void {
		TracedChild.halt(this.child, tracer);
	}

	/**
	 * Lists the root.
	 *
	 * @return A new array holding the root.
	 */
	public function children():Array<Node> {
		return [this.child];
	}

	/**
	 * Reports every node executed or halted in this tree to `tracer`, from the root down.
	 * The tracer is handed to the parent nodes in the tree now, so call it again after adding nodes to the tree.
	 *
	 * @param tracer - The tracer, e.g. a `StatusRecorder`; null to stop tracing.
	 */
	public function setTracer(tracer:Null<ITreeTracer>):Void {
		this.tracer = tracer;
		TracedChild.passOn([this.child], tracer);
	}

	/**
	 * Names a node in this tree's dumps, in place of any label the node has of its own (a Task node's Task name).
	 *
	 * @param node - The node to name.
	 * @param label - The name; null removes it.
	 */
	public function setLabel(node:Node, label:Null<String>):Void {
		if (label == null) {
			labels.remove(node);
		} else {
			labels.set(node, label);
		}
	}

	/**
	 * Gives a node's label: the one set with `setLabel`, else the node's own (`ILabeled`), else null.
	 *
	 * @param node - The node asked about.
	 * @return The label, or null for none.
	 */
	public function labelOf(node:Node):Null<String> {
		var label = labels.get(node);
		if (label != null) {
			return label;
		}

		var hasOwnLabel = Std.isOfType(node, ILabeled);
		if (hasOwnLabel) {
			var labeled:ILabeled = cast node;
			return labeled.getLabel();
		}
		return null;
	}

	/**
	 * Writes the tree as indented text, one node per line: its class name, its quoted label if it has one, and with a recorder
	 * its last Status ("-" if it has not run) and "(halted)" if it was halted.
	 *
	 * @param recorder - The `StatusRecorder` traced into this tree; leave out to print names only.
	 * @return The text, lines joined with newlines.
	 */
	public function toText(?recorder:StatusRecorder):String {
		return TreeDump.toText(this.child, nameOf, recorder);
	}

	/**
	 * Writes the tree as a Graphviz digraph, one DOT node per tree node by identity, labelled like `toText`.
	 * With a recorder, nodes that ran or were halted get a `class` attribute: "success", "failure" or "running", and/or "halted".
	 *
	 * @param recorder - The `StatusRecorder` traced into this tree; leave out for no classes.
	 * @return The DOT source.
	 */
	public function toDot(?recorder:StatusRecorder):String {
		return TreeDump.toDot(this.child, nameOf, recorder);
	}

	private function nameOf(node:Node):String {
		var nodeClass = Type.getClass(node);
		var fullName = nodeClass == null ? "Node" : Type.getClassName(nodeClass);
		var className = fullName.substr(fullName.lastIndexOf(".") + 1);
		var label = labelOf(node);
		return label == null ? className : '$className "$label"';
	}
}
