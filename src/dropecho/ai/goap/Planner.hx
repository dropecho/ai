package dropecho.ai.goap;

import dropecho.ds.Graph;
import dropecho.ds.IGraphNode;
import dropecho.ds.Queue;
import dropecho.ds.graph.Search;
import dropecho.interop.AbstractArray;
import dropecho.interop.AbstractMap;
import haxe.Json;

private typedef WorldStateGraph = Graph<Array<String>, Action>;
private typedef WorldStateNode = IGraphNode<Array<String>, Action>;

/**
 * Finds the cheapest Plan from the current world state to a Goal using the given Actions.
 */
@:expose("goap.Planner")
class Planner {
	private var _availableActions:AbstractArray<Action>;
	private var _goal:Goal;
	private var _worldState:Null<WorldStateProvider>;

	/**
	 * Creates a Planner for one Goal.
	 *
	 * @param goal - The Goal to reach.
	 * @param availableActions - The Actions the Plan may use; the Planner never changes this list.
	 * @param worldState - Returns the Condition names true in the game right now; planning starts there, or from the empty world state if left out. The Planner gives it to every Plan it returns.
	 */
	public function new(goal:Goal, availableActions:AbstractArray<Action>, ?worldState:WorldStateProvider) {
		_goal = goal;
		_availableActions = availableActions;
		_worldState = worldState;
	}

	/**
	 * Plans from the current world state to the Goal by total Cost; among equal-cost Actions the first given wins.
	 * Throws, like `Plan.new`, if the Plan would hold an Action that has no done check and there is no world state provider.
	 *
	 * @return The cheapest Plan, or null if the Goal cannot be reached.
	 */
	public function generatePlan():Null<Plan> {
		var graph = new WorldStateGraph();
		var startConditions = _startConditions();
		var start = graph.createNode(startConditions, _stateKey(startConditions));
		var goalNodes = _expandWorldStates(graph, start);

		var search = Search.dijkstra(start, (from, to) -> _actionCost(graph, from, to));
		var goal = _cheapestGoal(goalNodes, search);
		if (goal == null) {
			return null;
		}

		return _planTo(goal, start, graph, search);
	}

	/**
	 * Adds every world state reachable from `start` to the graph, with an edge for the
	 * cheapest action between each pair.
	 *
	 * @param graph - The graph to fill.
	 * @param start - The starting world state's node, already in the graph.
	 * @return The nodes that satisfy the Goal, in the order they were reached.
	 */
	private function _expandWorldStates(graph:WorldStateGraph, start:WorldStateNode):Array<WorldStateNode> {
		var frontier = new Queue<WorldStateNode>();
		var goalNodes = new Array<WorldStateNode>();
		frontier.enqueue(start);

		while (frontier.length > 0) {
			var current = frontier.dequeue();
			var conditions = current.value;

			if (_hasAll(conditions, _goal.conditions)) {
				goalNodes.push(current);
			}

			for (action in _availableActions) {
				if (_hasAll(conditions, action.Preconditions)) {
					var nextConditions = _withConditions(conditions, action.Postconditions);
					var nextKey = _stateKey(nextConditions);

					var isNewWorldState = graph.nodes.exists(nextKey) == false;
					if (isNewWorldState) {
						frontier.enqueue(graph.createNode(nextConditions, nextKey));
					}

					var existing = graph.edgeData(current.label, nextKey);
					var isCheapestSoFar = existing == null || existing.Cost > action.Cost;
					if (isCheapestSoFar) {
						graph.addUniEdge(current.label, nextKey, action);
					}
				}
			}
		}

		return goalNodes;
	}

	private function _actionCost(graph:WorldStateGraph, from:WorldStateNode, to:WorldStateNode):Float {
		var action = graph.edgeData(from.label, to.label);
		return action != null ? action.Cost : Math.POSITIVE_INFINITY;
	}

	private function _cheapestGoal(goalNodes:Array<WorldStateNode>, search:SearchResult<Array<String>, Action>):Null<WorldStateNode> {
		var cheapest:Null<WorldStateNode> = null;
		var cheapestCost = Math.POSITIVE_INFINITY;
		for (node in goalNodes) {
			var cost:Float = search.distances[node];
			var isCheaper = cost < cheapestCost;
			if (isCheaper) {
				cheapestCost = cost;
				cheapest = node;
			}
		}
		return cheapest;
	}

	/**
	 * Follows the search's path back from the Goal to collect the actions in the order they run.
	 *
	 * @param goal - The node that satisfies the Goal.
	 * @param start - The starting world state's node.
	 * @param graph - The expanded graph.
	 * @param search - Dijkstra's result from `start`.
	 * @return The plan, or null if the path is broken.
	 */
	private function _planTo(
		goal:WorldStateNode,
		start:WorldStateNode,
		graph:WorldStateGraph,
		search:SearchResult<Array<String>, Action>
	):Null<Plan> {
		var actions = new AbstractArray<Action>();
		var current = goal;
		while (current != start) {
			var prevLabel:String = search.path[current];
			if (prevLabel == null) {
				return null;
			}
			var action = graph.edgeData(prevLabel, current.label);
			if (action == null) {
				return null;
			}
			actions.unshift(action);
			current = graph.nodes.get(prevLabel);
		}

		return new Plan(actions, _worldState);
	}

	private function _startConditions():Array<String> {
		var current = _worldState != null ? _worldState() : [];
		return _withConditions([], current);
	}

	/**
	 * Names a world state by its sorted Condition names, JSON-encoded so a name containing `,` stays distinct.
	 *
	 * @param conditions - The world state's Condition names, in any order.
	 * @return The world state's graph label.
	 */
	private function _stateKey(conditions:Array<String>):String {
		var sorted = conditions.copy();
		sorted.sort(Reflect.compare);
		return Json.stringify(sorted);
	}

	private function _hasAll(conditions:Array<String>, required:Array<String>):Bool {
		for (condition in required) {
			var isMissing = conditions.indexOf(condition) < 0;
			if (isMissing) {
				return false;
			}
		}
		return true;
	}

	private function _withConditions(conditions:Array<String>, added:Array<String>):Array<String> {
		var result = conditions.copy();
		for (condition in added) {
			var isNew = result.indexOf(condition) < 0;
			if (isNew) {
				result.push(condition);
			}
		}
		return result;
	}
}
