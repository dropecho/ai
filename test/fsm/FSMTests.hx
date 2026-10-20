package fsm;

import utest.Test;
import dropecho.ai.fsm.*;
import dropecho.ai.Blackboard;
import utest.Assert;

class BlackboardState {
	var _bb:Blackboard;
	var _name:String;

	public function new(bb:Blackboard) {
		_bb = bb;
	}

	public function getName() {
		if (_name == null) {
			_name = Type.getClassName(Type.getClass(this));
		}
		return _name;
	}

	public function onEnter() {}

	public function onExit() {}
}

class WanderState extends BlackboardState implements IState {
	public function tick() {
		_bb.increment('hunger');
	}
}

class EatingState extends BlackboardState implements IState {
	public function tick() {
		_bb.decrement('hunger');
	}
}

class CountingState implements IState {
	var _name:String;

	public var enters = 0;
	public var exits = 0;

	public function new(name:String) {
		_name = name;
	}

	public function getName() {
		return _name;
	}

	public function onEnter() {
		enters++;
	}

	public function onExit() {
		exits++;
	}

	public function tick() {}
}

class FSMTests extends Test {
	private var _bb:Blackboard;
	private var _st1:WanderState;
	private var _st2:EatingState;
	private var _fsm:FSM;

	public function setup() {
		_bb = new Blackboard();
		_bb.set('hunger', 0);
		_st1 = new WanderState(_bb);
		_st2 = new EatingState(_bb);

		_fsm = new FSM();

		_fsm.changeToState(_st1);
		_fsm.addTransition(_st1, _st2, () -> _bb.get('hunger') > 2);
		_fsm.addTransition(_st2, _st1, () -> _bb.get('hunger') <= 0);
	}

	public function test_starting_state_runs() {
		_fsm.tick();
		Assert.equals(1, _bb.get("hunger"));
		_fsm.tick();
		Assert.equals(2, _bb.get("hunger"));
	}

	public function test_transitions_work() {
		// start in wander state.
		_fsm.tick();
		Assert.equals(1, _bb.get("hunger"));
		_fsm.tick();
		Assert.equals(2, _bb.get("hunger"));
		_fsm.tick();
		Assert.equals(3, _bb.get("hunger"));

		// run eat state.
		_fsm.tick();
		Assert.equals(2, _bb.get("hunger"));
		_fsm.tick();
		Assert.equals(1, _bb.get("hunger"));
		_fsm.tick();
		Assert.equals(0, _bb.get("hunger"));

		// wander state
		_fsm.tick();
		Assert.equals(1, _bb.get("hunger"));
		_fsm.tick();
		Assert.equals(2, _bb.get("hunger"));
		_fsm.tick();
		Assert.equals(3, _bb.get("hunger"));

		// switch to eat
		_fsm.tick();
		Assert.equals(2, _bb.get("hunger"));
	}

	public function test_tick_before_change_to_state_throws() {
		var fsm2 = new FSM();
		var threw = false;
		try {
			fsm2.tick();
		} catch (e:Dynamic) {
			threw = true;
		}
		Assert.isTrue(threw);
	}

	public function test_any_transitions_work() {
		var bb2 = new Blackboard();
		bb2.set('hunger', 0);

		var fsm2 = new FSM();
		var ws = new WanderState(bb2);
		var es = new EatingState(bb2);

		fsm2.changeToState(ws);
		fsm2.addAnyTransition(es, () -> bb2.get('hunger') > 0);

		fsm2.tick();

		Assert.equals(es, fsm2.getCurrentState());
	}

	public function test_toDot_contains_state_names() {
		var bb2 = new Blackboard();
		bb2.set('hunger', 0);

		var fsm2 = new FSM();
		var ws = new WanderState(bb2);
		var es = new EatingState(bb2);

		fsm2.changeToState(ws);
		fsm2.addAnyTransition(es, () -> bb2.get('hunger') > 0);

		var dot = fsm2.toDot();
		Assert.isTrue(dot.indexOf("digraph") >= 0);
		Assert.isTrue(dot.indexOf("EatingState") >= 0);
	}

	public function test_states_with_the_same_name_keep_their_own_transitions() {
		var bb2 = new Blackboard();
		var firstWander = new WanderState(bb2);
		var secondWander = new WanderState(bb2);
		var eat = new EatingState(bb2);

		var fsm2 = new FSM();
		fsm2.addTransition(firstWander, eat, () -> true);
		fsm2.changeToState(secondWander);
		fsm2.tick();

		Assert.equals(secondWander, fsm2.getCurrentState());
	}

	public function test_toDot_before_any_state_does_not_throw() {
		var fsm2 = new FSM();
		fsm2.addTransition(_st1, _st2, () -> false);
		Assert.isTrue(fsm2.toDot().indexOf("digraph") >= 0);
	}

	public function test_any_transition_to_the_current_state_is_not_taken() {
		var flee = new CountingState("flee");
		var fsm2 = new FSM();
		fsm2.addAnyTransition(flee, () -> true);
		fsm2.changeToState(flee);

		fsm2.tick();
		fsm2.tick();

		Assert.equals(flee, fsm2.getCurrentState());
		Assert.equals(1, flee.enters);
		Assert.equals(0, flee.exits);
	}

	public function test_transition_to_the_current_state_is_skipped_for_the_next_one() {
		var idle = new CountingState("idle");
		var walk = new CountingState("walk");
		var fsm2 = new FSM();
		fsm2.addAnyTransition(idle, () -> true);
		fsm2.addTransition(idle, idle, () -> true);
		fsm2.addTransition(idle, walk, () -> true);
		fsm2.changeToState(idle);

		fsm2.tick();

		Assert.equals(walk, fsm2.getCurrentState());
		Assert.equals(1, idle.enters);
		Assert.equals(1, idle.exits);
	}
}
