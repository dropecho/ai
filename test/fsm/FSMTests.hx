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

class WanderState extends BlackboardState implements IState {
	public function getName() {
		return "WanderState";
	}

	public function onEnter() {}

	public function onExit() {}

	public function tick() {
		bb.increment('some_fact');
	}
}

class EatingState extends BlackboardState implements IState {
	public function getName() {
		return "EatingState";
	}

	public function onEnter() {}

	public function onExit() {}

	public function tick() {
		bb.decrement('some_fact');
	}
}

class FSMTests extends Test {
	private var bb:Blackboard;
	private var st1:WanderState;
	private var st2:EatingState;
	private var fsm:FSM;

	public function setup() {
		bb = new Blackboard();
		bb.set('some_fact', 0);
		st1 = new WanderState(bb);
		st2 = new EatingState(bb);

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

	public function test_any_transitions_work() {
		var bb2 = new Blackboard();
		bb2.set('hunger', 0);
		bb2.set('some_fact', 0);

		var fsm2 = new FSM();
		var ws = new WanderState(bb2);
		var es = new EatingState(bb2);

		fsm2.changeToState(ws);
		fsm2.addAnyTransition(es, () -> bb2.get('hunger') > 0);
		fsm2.addAnyTransition(ws, () -> bb2.get('some_fact') > 5);

		fsm2.tick();
		Assert.equals(1, bb2.get("some_fact"));
	}

	public function test_toDot_contains_state_names() {
		var bb2 = new Blackboard();
		bb2.set('hunger', 0);
		bb2.set('some_fact', 0);

		var fsm2 = new FSM();
		var ws = new WanderState(bb2);
		var es = new EatingState(bb2);

		fsm2.changeToState(ws);
		fsm2.addAnyTransition(es, () -> bb2.get('hunger') > 0);
		fsm2.addAnyTransition(ws, () -> bb2.get('some_fact') > 5);

		var dot = fsm2.toDot();
		Assert.isTrue(dot.indexOf("EatingState") >= 0);
	}
}
