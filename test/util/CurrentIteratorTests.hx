package util;

import utest.Test;
import utest.Assert;
import dropecho.util.CurrentIterator;

class CurrentIteratorTests extends Test {
	private var array:Array<Int>;
	private var iter:CurrentIterator<Int>;

	public function setup() {
		array = new Array<Int>();

		array.push(0);
		array.push(1);
		array.push(2);
		array.push(3);

		iter = new CurrentIterator<Int>(array);
	}

	public function test_current_iterator_should_start_at_first_node() {
		Assert.equals(0, iter.current());
	}

	public function test_current_iterator_next_should_give_first_item() {
		Assert.equals(0, iter.next());
	}

	public function test_calling_next_should_increment_item_given_by_current() {
		iter.next();
		Assert.equals(1, iter.current());
	}

	public function test_has_next_should_return_true_when_iterator_is_not_at_end_of_array() {
		Assert.isTrue(iter.hasNext());
	}

	public function test_has_next_should_return_false_when_iterator_is_at_end_of_array() {
		iter.next();
		iter.next();
		iter.next();
		iter.next();
		Assert.isFalse(iter.hasNext());
	}
}
