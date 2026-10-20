package bt.node.composite;

import utest.Test;
import utest.Assert;
import dropecho.ai.bt.node.Node;
import dropecho.ai.bt.node.composite.ChildCursor;

class ChildCursorTests extends Test {
	private var children:Array<Node>;
	private var cursor:ChildCursor;

	public function setup() {
		children = [new TestNode(), new TestNode(), new TestNode(), new TestNode()];
		cursor = new ChildCursor(children);
	}

	public function test_cursor_should_start_at_first_child() {
		Assert.equals(children[0], cursor.current());
	}

	public function test_current_should_not_move_the_cursor() {
		cursor.current();
		Assert.equals(children[0], cursor.current());
	}

	public function test_advance_should_move_to_the_next_child() {
		cursor.advance();
		Assert.equals(children[1], cursor.current());
	}

	public function test_is_on_last_should_be_false_before_the_last_child() {
		cursor.advance();
		cursor.advance();
		Assert.isFalse(cursor.isOnLast());
	}

	public function test_is_on_last_should_be_true_on_the_last_child() {
		cursor.advance();
		cursor.advance();
		cursor.advance();
		Assert.equals(children[3], cursor.current());
		Assert.isTrue(cursor.isOnLast());
	}

	public function test_is_on_last_should_be_true_with_one_child() {
		cursor = new ChildCursor([new TestNode()]);
		Assert.isTrue(cursor.isOnLast());
	}

	public function test_reset_should_return_to_the_first_child() {
		cursor.advance();
		cursor.advance();
		cursor.reset();
		Assert.equals(children[0], cursor.current());
		Assert.isFalse(cursor.isOnLast());
	}
}
