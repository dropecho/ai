package fsm;

import utest.Test;
import dropecho.ai.fsm.*;
import dropecho.ai.Blackboard;
import utest.Assert;

class BlackboardState {
	private var bb:Blackboard;

	public function new(bb:Blackboard) {
		this.bb = bb;
	}
}

class TestState1 extends BlackboardState implements IState {
	public function getName() {
		return "TestState1";
	}

	public function onEnter() {}

	public function onExit() {}

	public function tick() {
		bb.increment('some_fact');
	}
}

class TestState2 extends BlackboardState implements IState {
	public function getName() {
		return "TestState2";
	}

	public function onEnter() {}

	public function onExit() {}

	public function tick() {
		bb.decrement('some_fact');
	}
}

class FSMTests extends Test {
	private var bb:Blackboard;
	private var st1:TestState1;
	private var st2:TestState2;
	private var fsm:FSM;

	public function setup() {
		bb = new Blackboard();
		bb.set('some_fact', 0);
		st1 = new TestState1(bb);
		st2 = new TestState2(bb);

		this.fsm = new FSM();

		this.fsm.changeToState(st1);
		//     fsm.addTransition(st1, st2, () -> bb.get('some_fact') > 2);
	}

	public function test_starting_state_runs() {
		fsm.tick();
		Assert.equals(1, bb.get("some_fact"));
		//     fsm.tick();
		//     Assert.equals(2, bb.get("some_fact"));
	}

	public function test_transitions_work() {
		fsm.tick();
		Assert.equals(1, bb.get("some_fact"));
		//     fsm.tick();
		//     Assert.equals(2, bb.get("some_fact"));
		//     fsm.tick();
		//     Assert.equals(3, bb.get("some_fact"));
		//     fsm.tick();
		//     Assert.equals(2, bb.get("some_fact"));
		//     fsm.tick();
		//     Assert.equals(1, bb.get("some_fact"));
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
