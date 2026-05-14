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

	public function test_any_transition_fires_from_any_state() {
		var bb2 = new Blackboard();
		bb2.set('hunger', 0);
		var wander = new TestState1(bb2);
		var eating = new TestState2(bb2);
		var fsm2 = new FSM();
		fsm2.changeToState(wander);
		fsm2.addAnyTransition(eating, _ -> bb2.get('hunger') > 0);
		bb2.set('hunger', 1);
		fsm2.tick();
		Assert.equals(eating, fsm2.getCurrentState());
	}

	public function test_toDot_contains_state_names() {
		var bb2 = new Blackboard();
		bb2.set('some_fact', 0);
		var s1 = new TestState1(bb2);
		var s2 = new TestState2(bb2);
		var fsm2 = new FSM();
		fsm2.changeToState(s1);
		fsm2.addAnyTransition(s2, _ -> bb2.get('some_fact') > 5);
		var dot = fsm2.toDot();
		Assert.isTrue(dot.indexOf("digraph") >= 0);
		Assert.isTrue(dot.indexOf("TestState2") >= 0);
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
}
