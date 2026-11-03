package fsm;

/** Reads the nodes and edges of a DOT graph, one statement per line, naming each node by its label so tests don't depend on DOT ids. */
class DotGraph {
	static var ID = '"(?:[^"\\\\]|\\\\.)*"|[\\w.]+';

	var _labels = new Map<String, String>();
	var _nodeClasses = new Map<String, Null<String>>();
	var _edges = new Array<{from:String, to:String, cls:Null<String>}>();

	/**
	 * Parses `dot`.
	 *
	 * @param dot - The DOT source.
	 */
	public function new(dot:String) {
		var edgeLine = new EReg('^(' + ID + ')\\s*->\\s*(' + ID + ')\\s*(?:\\[(.*)\\])?;?' + "$", "");
		var nodeLine = new EReg('^(' + ID + ')\\s*(?:\\[(.*)\\])?;?' + "$", "");
		for (rawLine in dot.split("\n")) {
			var line = StringTools.trim(rawLine);
			if (edgeLine.match(line)) {
				_edges.push({from: unquote(edgeLine.matched(1)), to: unquote(edgeLine.matched(2)), cls: classOf(edgeLine.matched(3))});
			} else if (nodeLine.match(line)) {
				var id = unquote(nodeLine.matched(1));
				var attrs = nodeLine.matched(2);
				var label = ~/label="((?:[^"\\]|\\.)*)"/;
				var hasLabel = attrs != null && label.match(attrs);
				if (hasLabel) {
					_labels.set(id, unquote('"' + label.matched(1) + '"'));
				}
				_nodeClasses.set(id, classOf(attrs));
			}
		}
	}

	/**
	 * Lists the edges as `from -> to`, by node label.
	 *
	 * @return The edges, in order.
	 */
	public function edges():Array<String> {
		return [for (e in _edges) '${labelOf(e.from)} -> ${labelOf(e.to)}'];
	}

	/**
	 * Lists the edges with class `cls`, as `from -> to` by node label.
	 *
	 * @param cls - The class to look for.
	 * @return The matching edges, in order.
	 */
	public function edgesWithClass(cls:String):Array<String> {
		return [for (e in _edges) if (e.cls == cls) '${labelOf(e.from)} -> ${labelOf(e.to)}'];
	}

	/**
	 * Lists the labels of the declared nodes.
	 *
	 * @return The node labels.
	 */
	public function nodes():Array<String> {
		return [for (id in _nodeClasses.keys()) labelOf(id)];
	}

	/**
	 * Lists the labels of the declared nodes with class `cls`.
	 *
	 * @param cls - The class to look for.
	 * @return The matching node labels.
	 */
	public function nodesWithClass(cls:String):Array<String> {
		return [for (id => c in _nodeClasses) if (c == cls) labelOf(id)];
	}

	function labelOf(id:String):String {
		return _labels.exists(id) ? _labels.get(id) : id;
	}

	static function classOf(attrs:Null<String>):Null<String> {
		var cls = ~/class="(\w+)"/;
		var hasClass = attrs != null && cls.match(attrs);
		return hasClass ? cls.matched(1) : null;
	}

	static function unquote(id:String):String {
		var isQuoted = StringTools.startsWith(id, '"');
		if (isQuoted) {
			return StringTools.replace(id.substr(1, id.length - 2), '\\"', '"');
		}
		return id;
	}
}
