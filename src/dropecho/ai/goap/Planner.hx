package dropecho.ai.goap;

import dropecho.interop.AbstractArray;

class Planner {
	private var _availableActions:AbstractArray<Action>;
	private var _goal:State;

	public function new(goal:State, availableActions:AbstractArray<Action>) {
		_goal = goal;
		_availableActions = availableActions;
		_availableActions.sort((a:Action, b:Action) -> a.Cost - b.Cost);
	}

	public function generatePlan() {
		var plan = new AbstractArray<Action>();

		// Build base set of preconditions
		var preconditions = [].concat(_goal.Preconditions);

		while (preconditions.length > 0) {
			// For each precondition, find the best action that will satisfy it.
			var bestMatch = findBestMatch(preconditions.shift());

			// No actions satisfy precondition, so plan cannot be generated.
			if (bestMatch == null) {
				return null;
			}

			// Add match to plan.
			plan.unshift(bestMatch);

			// Add preconditions from action, so we can satisfy the new action.
			preconditions = bestMatch.Preconditions.concat(preconditions);
		}

		return new Plan(plan);
	}

	private function findBestMatch(precondition:String) {
		var postConditionMatcher = function(postcondition:String) {
			return postcondition == precondition;
		};

		var actionMatcher = function(action:Action) {
			return action.Postconditions
				.filter(postConditionMatcher)
				.length > 0;
		};

		var matches = _availableActions.filter(actionMatcher);

		return matches.length > 0 ? matches[0] : null;
	}
}
