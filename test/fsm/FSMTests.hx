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
}
