package bt.trace;

import utest.Test;
import utest.Assert;
import dropecho.ai.Blackboard;
import dropecho.ai.bt.BehaviorTree;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.bt.node.composite.ParallelNode;
import dropecho.ai.bt.node.composite.SelectorNode;
import dropecho.ai.bt.node.composite.SequenceNode;
import dropecho.ai.bt.node.decorator.AbortMode;
import dropecho.ai.bt.node.decorator.CooldownNode;
import dropecho.ai.bt.node.decorator.GuardNode;
import dropecho.ai.bt.node.decorator.InverterNode;
import dropecho.ai.bt.node.decorator.RepeaterNode;
import dropecho.ai.bt.node.decorator.RetryNode;
import dropecho.ai.bt.node.decorator.TimeoutNode;
import dropecho.ai.bt.trace.StatusRecorder;
import bt.node.TestNode;

class TracerTests extends Test {
	private var log:LogTracer;

	public function setup() {
		log = new LogTracer();
	}

	private function tracedTree(root:Node):BehaviorTree {
		var tree = new BehaviorTree(root);
		tree.init(new Blackboard());
		tree.setTracer(log);
		return tree;
	}

	public function test_every_executed_node_is_reported_after_it_returns_children_first() {
		var a = log.name(new TestNode(), "a");
		var b = log.name(new TestNode(NODE_STATUS.RUNNING), "b");
		var tree = tracedTree(log.name(new SequenceNode([a, b]), "seq"));

		tree.execute(0.5);

		Assert.same(["tick a SUCCESS", "tick b RUNNING", "tick seq RUNNING"], log.events);
	}

	public function test_nodes_not_reached_are_not_reported() {
		var a = log.name(new TestNode(NODE_STATUS.FAILURE), "a");
		var b = log.name(new TestNode(), "b");
		var tree = tracedTree(log.name(new SequenceNode([a, b]), "seq"));

		tree.execute(0);

		Assert.same(["tick a FAILURE", "tick seq FAILURE"], log.events);
	}

	public function test_a_reactive_composite_reports_the_child_it_abandons_as_halted() {
		var guard = log.name(new TestNode(NODE_STATUS.FAILURE), "guard");
		var running = log.name(new TestNode(NODE_STATUS.RUNNING), "running");
		var tree = tracedTree(log.name(new SelectorNode([guard, running], true), "sel"));

		tree.execute(0);
		log.events = [];
		guard.execReturn = NODE_STATUS.SUCCESS;
		tree.execute(0);

		Assert.same(["tick guard SUCCESS", "halt running", "tick sel SUCCESS"], log.events);
	}

	public function test_decorators_report_their_child() {
		var a = log.name(new TestNode(), "a");
		var tree = tracedTree(log.name(new InverterNode(a), "inv"));

		tree.execute(0);

		Assert.same(["tick a SUCCESS", "tick inv FAILURE"], log.events);
	}

	public function test_a_repeater_reports_each_run_of_its_child() {
		var a = log.name(new TestNode(), "a");
		var tree = tracedTree(log.name(new RepeaterNode(a, 3), "rep"));

		tree.execute(0);

		Assert.same(["tick a SUCCESS", "tick a SUCCESS", "tick a SUCCESS", "tick rep SUCCESS"], log.events);
	}

	public function test_a_retry_reports_each_attempt() {
		var a = log.name(new TestNode(NODE_STATUS.FAILURE), "a");
		var tree = tracedTree(log.name(new RetryNode(a, 2), "retry"));

		tree.execute(0);

		Assert.same(["tick a FAILURE", "tick a FAILURE", "tick retry FAILURE"], log.events);
	}

	public function test_a_parallel_reports_its_children_and_the_running_ones_it_halts() {
		var a = log.name(new TestNode(), "a");
		var b = log.name(new TestNode(NODE_STATUS.RUNNING), "b");
		var c = log.name(new TestNode(NODE_STATUS.FAILURE), "c");
		var tree = tracedTree(log.name(new ParallelNode([a, b, c]), "par"));

		tree.execute(0);

		Assert.same(["tick a SUCCESS", "tick b RUNNING", "tick c FAILURE", "halt b", "tick par FAILURE"], log.events);
	}

	public function test_a_lower_priority_abort_reports_the_halted_sibling() {
		var isAllowed = false;
		var guarded = log.name(new TestNode(NODE_STATUS.RUNNING), "guarded");
		var guard = log.name(new GuardNode(context -> isAllowed, guarded, AbortMode.LOWER_PRIORITY), "guard");
		var low = log.name(new TestNode(NODE_STATUS.RUNNING), "low");
		var tree = tracedTree(log.name(new SelectorNode([guard, low]), "sel"));

		tree.execute(0);
		log.events = [];
		isAllowed = true;
		tree.execute(0);

		Assert.same(["halt low", "tick guarded RUNNING", "tick guard RUNNING", "tick sel RUNNING"], log.events);
	}

	public function test_a_guard_reports_halting_its_child_when_its_check_turns_false() {
		var isAllowed = true;
		var child = log.name(new TestNode(NODE_STATUS.RUNNING), "child");
		var tree = tracedTree(log.name(new GuardNode(context -> isAllowed, child), "guard"));

		tree.execute(0);
		log.events = [];
		isAllowed = false;
		tree.execute(0);

		Assert.same(["halt child", "tick guard FAILURE"], log.events);
	}

	public function test_a_timeout_reports_halting_its_child_when_time_runs_out() {
		var child = log.name(new TestNode(NODE_STATUS.RUNNING), "child");
		var tree = tracedTree(log.name(new TimeoutNode(child, 1), "timeout"));

		tree.execute(0);
		log.events = [];
		tree.execute(2);

		Assert.same(["halt child", "tick timeout FAILURE"], log.events);
	}

	public function test_a_cooling_down_cooldown_reports_no_child_run() {
		var child = log.name(new TestNode(), "child");
		var tree = tracedTree(log.name(new CooldownNode(child, 5), "cooldown"));

		tree.execute(0);
		tree.execute(1);

		Assert.same(["tick child SUCCESS", "tick cooldown SUCCESS", "tick cooldown FAILURE"], log.events);
	}

	public function test_halting_the_tree_reports_the_halted_branch_from_the_top_down() {
		var b = log.name(new TestNode(NODE_STATUS.RUNNING), "b");
		var tree = tracedTree(log.name(new SequenceNode([b]), "seq"));

		tree.execute(0);
		log.events = [];
		tree.halt();

		Assert.same(["halt seq", "halt b"], log.events);
		Assert.equals(1, b.halted);
	}

	public function test_a_null_tracer_stops_reporting() {
		var tree = tracedTree(log.name(new SequenceNode([new TestNode()]), "seq"));

		tree.setTracer(null);
		tree.execute(0);

		Assert.same([], log.events);
	}

	public function test_tracing_does_not_change_what_the_tree_does() {
		function run(withTracer:Bool):Array<Int> {
			var first = new TestNode(NODE_STATUS.FAILURE);
			var running = new TestNode(NODE_STATUS.RUNNING);
			var tree = new BehaviorTree(new SelectorNode([first, running], true));
			tree.init(new Blackboard());
			if (withTracer) {
				tree.setTracer(new StatusRecorder());
			}

			var statuses:Array<Int> = [tree.execute(0)];
			first.execReturn = NODE_STATUS.SUCCESS;
			statuses.push(tree.execute(0));
			return statuses.concat([first.executed, running.executed, running.halted]);
		}

		Assert.same(run(false), run(true));
	}

	public function test_children_returns_a_copy() {
		var a = new TestNode();
		var sequence = new SequenceNode([a]);

		var children = sequence.children();
		children.push(new TestNode());

		Assert.equals(1, sequence.children().length);
		Assert.equals(a, sequence.children()[0]);
	}

	public function test_status_recorder_remembers_the_last_status_and_halts_until_cleared() {
		var recorder = new StatusRecorder();
		var running = new TestNode(NODE_STATUS.RUNNING);
		var sequence = new SequenceNode([running]);
		var tree = new BehaviorTree(sequence);
		tree.init(new Blackboard());
		tree.setTracer(recorder);

		tree.execute(0);
		tree.halt();

		Assert.equals(NODE_STATUS.RUNNING, recorder.statusOf(running));
		Assert.isTrue(recorder.wasHalted(running));
		recorder.clear();
		Assert.isNull(recorder.statusOf(running));
		Assert.isFalse(recorder.wasHalted(sequence));
	}
}
