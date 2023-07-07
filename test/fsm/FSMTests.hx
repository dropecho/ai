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
}
