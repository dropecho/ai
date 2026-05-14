package dropecho.ai.goap;

import dropecho.ds.Graph;
import dropecho.ds.IGraphNode;
import dropecho.ds.Queue;
import dropecho.ds.Set;
import dropecho.ds.graph.Search;
import dropecho.interop.AbstractArray;
import dropecho.interop.AbstractMap;

class Planner {
	private var _availableActions:AbstractArray<Action>;
	private var _goal:State;

	public function new(goal:State, availableActions:AbstractArray<Action>) {
		_goal = goal;
		// Copy so we never mutate the caller's array
		_availableActions = cast [for (a in availableActions) a];
		_availableActions.sort((a:Action, b:Action) -> Reflect.compare(a.Cost, b.Cost));
	}

	public function generatePlan():Null<Plan> {
		var graph = new Graph<String, Action>();

		var startKey = "";
		graph.createNode(startKey, startKey);

		// BFS to expand the reachable state space
		var frontier = new Queue<IGraphNode<String, Action>>();
		var visited = new Set<String>(_stringHash);
		var goalNodes = new Array<IGraphNode<String, Action>>();

		frontier.enqueue(graph.nodes.get(startKey));
		visited.add(startKey);

		while (frontier.length > 0) {
			var current = frontier.dequeue();
			var conditions = _parseState(current.label);

			if (_satisfiesGoal(conditions)) {
				goalNodes.push(current);
			}

			for (action in _availableActions) {
				if (_preconditionsMet(conditions, action.Preconditions)) {
					var nextConditions = _applyPostconditions(conditions, action.Postconditions);
					var nextKey = _stateKey(nextConditions);

					if (!graph.nodes.exists(nextKey)) {
						graph.createNode(nextKey, nextKey);
						frontier.enqueue(graph.nodes.get(nextKey));
						visited.add(nextKey);
					}

					// Keep only the cheapest action for each state transition
					var existing = graph.edgeData(current.label, nextKey);
					if (existing == null || existing.Cost > action.Cost) {
						graph.addUniEdge(current.label, nextKey, action);
					}
				}
			}
		}

		if (goalNodes.length == 0) return null;

		// Dijkstra from start finds cheapest path to every reachable node
		var startNode = graph.nodes.get(startKey);
		var result = Search.dijkstra(startNode, (a, b) -> {
			var action = graph.edgeData(a.label, b.label);
			return action != null ? (action.Cost : Float) : Math.POSITIVE_INFINITY;
		});

		// Pick the goal node with the lowest Dijkstra cost
		var bestGoal:IGraphNode<String, Action> = null;
		var bestDist = Math.POSITIVE_INFINITY;
		for (gn in goalNodes) {
			var d:Float = result.distances[gn];
			if (d != null && d < bestDist) {
				bestDist = d;
				bestGoal = gn;
			}
		}

		if (bestGoal == null) return null;

		// Reconstruct ordered action sequence by following prev pointers
		var actions = new AbstractArray<Action>();
		var current = bestGoal;
		while (current.label != startKey) {
			var prevLabel:String = result.path[current];
			if (prevLabel == null) return null;
			var prev = graph.nodes.get(prevLabel);
			var action = graph.edgeData(prevLabel, current.label);
			if (action == null) return null;
			actions.unshift(action);
			current = prev;
		}

		return new Plan(actions);
	}

	// Stable string hash for Set<String>
	private static function _stringHash(s:String):Int {
		var h = 0;
		for (i in 0...s.length)
			h = 31 * h + s.charCodeAt(i);
		return h;
	}

	// Canonical sorted comma-joined key for a set of conditions
	private function _stateKey(conditions:Array<String>):String {
		var sorted = conditions.copy();
		sorted.sort(Reflect.compare);
		return sorted.join(",");
	}

	private function _parseState(key:String):Array<String> {
		return key == "" ? [] : key.split(",");
	}

	private function _satisfiesGoal(conditions:Array<String>):Bool {
		for (cond in _goal.Preconditions) {
			if (conditions.indexOf(cond) < 0) return false;
		}
		return true;
	}

	private function _preconditionsMet(conditions:Array<String>, preconditions:Array<String>):Bool {
		for (pre in preconditions) {
			if (conditions.indexOf(pre) < 0) return false;
		}
		return true;
	}

	private function _applyPostconditions(conditions:Array<String>, postconditions:Array<String>):Array<String> {
		var result = conditions.copy();
		for (post in postconditions) {
			if (result.indexOf(post) < 0) result.push(post);
		}
		return result;
	}
}
