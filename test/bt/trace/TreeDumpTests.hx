package bt.trace;

import utest.Test;
import utest.Assert;
import dropecho.ai.Blackboard;
import dropecho.ai.TaskBank;
import dropecho.ai.bt.BehaviorTree;
import dropecho.ai.bt.node.NODE_STATUS;
import dropecho.ai.bt.node.TaskNode;
import dropecho.ai.bt.node.composite.ParallelNode;
import dropecho.ai.bt.node.composite.SelectorNode;
import dropecho.ai.bt.node.composite.SequenceNode;
import dropecho.ai.bt.node.decorator.InverterNode;
import dropecho.ai.bt.trace.StatusRecorder;
import bt.node.TestNode;

class TreeDumpTests extends Test {
	private var hungry:TestNode;
	private var eat:TestNode;
	private var eatWhenHungry:SequenceNode;
	private var wander:TestNode;
	private var root:SelectorNode;
	private var tree:BehaviorTree;
	private var recorder:StatusRecorder;

	public function setup() {
		hungry = new TestNode(NODE_STATUS.FAILURE);
		eat = new TestNode(NODE_STATUS.RUNNING);
		eatWhenHungry = new SequenceNode([hungry, eat]);
		wander = new TestNode();
		root = new SelectorNode([eatWhenHungry, wander]);
		tree = new BehaviorTree(root);
		tree.init(new Blackboard());
		tree.setLabel(root, "root");
		tree.setLabel(eatWhenHungry, "eat when hungry");
		tree.setLabel(hungry, "is hungry");
		recorder = new StatusRecorder();
		tree.setTracer(recorder);
	}

	public function test_toText_without_a_recorder_lists_names_indented_by_depth() {
		var expected = [
			'SelectorNode "root"',
			'  SequenceNode "eat when hungry"',
			'    TestNode "is hungry"',
			'    TestNode',
			'  TestNode',
		].join("\n");

		Assert.equals(expected, tree.toText());
	}

	public function test_toText_shows_each_nodes_last_status_or_a_dash() {
		tree.execute(0);

		var expected = [
			'SelectorNode "root": SUCCESS',
			'  SequenceNode "eat when hungry": FAILURE',
			'    TestNode "is hungry": FAILURE',
			'    TestNode: -',
			'  TestNode: SUCCESS',
		].join("\n");

		Assert.equals(expected, tree.toText(recorder));
	}

	public function test_toText_marks_halted_nodes() {
		hungry.execReturn = NODE_STATUS.SUCCESS;
		tree.execute(0);
		recorder.clear();
		tree.halt();

		var expected = [
			'SelectorNode "root": - (halted)',
			'  SequenceNode "eat when hungry": - (halted)',
			'    TestNode "is hungry": -',
			'    TestNode: - (halted)',
			'  TestNode: -',
		].join("\n");

		Assert.equals(expected, tree.toText(recorder));
	}

	public function test_toDot_draws_nodes_by_identity_with_status_classes() {
		hungry.execReturn = NODE_STATUS.SUCCESS;
		tree.execute(0);

		var expected = [
			'digraph {',
			'  n0 [label="SelectorNode \\"root\\"", class="running"];',
			'  n1 [label="SequenceNode \\"eat when hungry\\"", class="running"];',
			'  n2 [label="TestNode \\"is hungry\\"", class="success"];',
			'  n3 [label="TestNode", class="running"];',
			'  n4 [label="TestNode"];',
			'  n1 -> n2;',
			'  n1 -> n3;',
			'  n0 -> n1;',
			'  n0 -> n4;',
			'}',
		].join("\n");

		Assert.equals(expected, tree.toDot(recorder));
	}

	public function test_toDot_marks_halted_nodes_with_or_without_a_status() {
		var a = new TestNode();
		var b = new TestNode(NODE_STATUS.RUNNING);
		var c = new TestNode(NODE_STATUS.FAILURE);
		var small = new BehaviorTree(new ParallelNode([a, b, c]));
		small.init(new Blackboard());
		var smallRecorder = new StatusRecorder();
		small.setTracer(smallRecorder);

		small.execute(0);
		var dot = small.toDot(smallRecorder);

		Assert.stringContains('n2 [label="TestNode", class="running halted"]', dot);
		Assert.stringContains('n3 [label="TestNode", class="failure"]', dot);
		smallRecorder.clear();
		small.halt();
		Assert.stringContains('n0 [label="ParallelNode", class="halted"]', small.toDot(smallRecorder));
	}

	public function test_a_node_shared_by_two_parents_is_drawn_once() {
		var shared = new TestNode();
		var small = new BehaviorTree(new SequenceNode([shared, new InverterNode(shared)]));

		var expected = [
			'digraph {',
			'  n0 [label="SequenceNode"];',
			'  n1 [label="TestNode"];',
			'  n2 [label="InverterNode"];',
			'  n0 -> n1;',
			'  n2 -> n1;',
			'  n0 -> n2;',
			'}',
		].join("\n");

		Assert.equals(expected, small.toDot());
	}

	public function test_toDot_escapes_quotes_and_backslashes_in_labels() {
		tree.setLabel(wander, 'say "hi" \\o/');

		Assert.stringContains('[label="TestNode \\"say \\"hi\\" \\\\o/\\""]', tree.toDot());
	}

	public function test_a_task_node_is_labelled_with_its_task_name_unless_the_tree_relabels_it() {
		TaskBank.register("dump_test_task", (bb:Blackboard, deltaTime:Float) -> NODE_STATUS.SUCCESS);
		var task = new TaskNode("dump_test_task");
		var small = new BehaviorTree(task);

		Assert.equals('TaskNode "dump_test_task"', small.toText());
		small.setLabel(task, "renamed");
		Assert.equals("renamed", small.labelOf(task));
		small.setLabel(task, null);
		Assert.equals("dump_test_task", small.labelOf(task));
	}

	public function test_an_unlabelled_node_has_no_label() {
		Assert.isNull(tree.labelOf(wander));
	}
}
