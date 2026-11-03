package dropecho.ai.bt.trace;

import haxe.ds.ObjectMap;
import dropecho.ai.bt.node.IParentNode;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;

/**
 * Writes a behavior tree out as indented text or Graphviz DOT, walking it through `IParentNode.children`.
 */
class TreeDump {
	/**
	 * Writes one line per node, children indented two spaces under their parent.
	 * With a recorder, each line ends with the node's last Status ("-" if it has not run) and "(halted)" if it was halted.
	 *
	 * @param root - The node to start from.
	 * @param nameOf - Gives the name printed for a node.
	 * @param recorder - Where the Statuses come from; null to print names only.
	 * @return The lines, joined with newlines.
	 */
	public static function toText(root:Node, nameOf:Node->String, recorder:Null<StatusRecorder>):String {
		var lines = new Array<String>();

		function write(node:Node, indent:String) {
			var line = indent + nameOf(node);
			if (recorder != null) {
				var status = recorder.statusOf(node);
				line += ": " + (status == null ? "-" : statusName(status));
				if (recorder.wasHalted(node)) {
					line += " (halted)";
				}
			}
			lines.push(line);

			for (child in childrenOf(node)) {
				write(child, indent + "  ");
			}
		}

		write(root, "");
		return lines.join("\n");
	}

	/**
	 * Writes a Graphviz digraph with one DOT node per tree node (ids by identity, so a shared node appears once) and an edge to each child.
	 * With a recorder, a node that ran or was halted gets a `class` of its lowercase last Status and/or "halted".
	 *
	 * @param root - The node to start from.
	 * @param nameOf - Gives the label drawn for a node.
	 * @param recorder - Where the Statuses come from; null for no classes.
	 * @return The DOT source.
	 */
	public static function toDot(root:Node, nameOf:Node->String, recorder:Null<StatusRecorder>):String {
		var nodeIds = new ObjectMap<Node, String>();
		var nodeLines = new Array<String>();
		var edgeLines = new Array<String>();

		function visit(node:Node):String {
			var isDeclared = nodeIds.exists(node);
			if (isDeclared) {
				return nodeIds.get(node);
			}

			var id = 'n${nodeLines.length}';
			nodeIds.set(node, id);
			nodeLines.push('  $id [${dotAttributes(node, nameOf, recorder)}];');
			for (child in childrenOf(node)) {
				edgeLines.push('  $id -> ${visit(child)};');
			}
			return id;
		}

		visit(root);
		return ["digraph {"].concat(nodeLines).concat(edgeLines).concat(["}"]).join("\n");
	}

	/**
	 * Gives a node's children if it is a parent node.
	 *
	 * @param node - The node.
	 * @return Its children, or an empty array for a leaf.
	 */
	private static function childrenOf(node:Node):Array<Node> {
		var isParent = Std.isOfType(node, IParentNode);
		if (isParent) {
			var parent:IParentNode = cast node;
			return parent.children();
		}
		return [];
	}

	private static function dotAttributes(node:Node, nameOf:Node->String, recorder:Null<StatusRecorder>):String {
		var attributes = ['label="${escapeDot(nameOf(node))}"'];
		if (recorder == null) {
			return attributes.join(", ");
		}

		var classes = new Array<String>();
		var status = recorder.statusOf(node);
		if (status != null) {
			classes.push(statusName(status).toLowerCase());
		}
		if (recorder.wasHalted(node)) {
			classes.push("halted");
		}
		if (classes.length > 0) {
			attributes.push('class="${classes.join(" ")}"');
		}
		return attributes.join(", ");
	}

	private static function escapeDot(text:String):String {
		var escaped = StringTools.replace(text, "\\", "\\\\");
		escaped = StringTools.replace(escaped, '"', '\\"');
		return StringTools.replace(escaped, "\n", "\\n");
	}

	private static function statusName(status:NODE_STATUS):String {
		return switch (status) {
			case NODE_STATUS.SUCCESS: "SUCCESS";
			case NODE_STATUS.FAILURE: "FAILURE";
			case NODE_STATUS.RUNNING: "RUNNING";
			case _: Std.string(status);
		}
	}
}
