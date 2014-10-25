package pathfinding;

import massive.munit.Assert;
import de.polygonal.ds.DA;
import de.polygonal.ds.Graph;
import de.polygonal.ds.Heap;
import com.dropecho.ai.pathfinding.AStar;
import com.dropecho.ai.pathfinding.AStarWaypoint;

class AStarTest {
	public var _path : DA<Waypoint<Int>>;
	public var _graph : Graph<Int>;
	public var _source : Waypoint<Int>;
	public var _target : Waypoint<Int>;

	@Before
	public function setup(){
		_graph = new Graph<Int>();
		_source = new Waypoint<Int>(_graph, 1);
		_target = new Waypoint<Int>(_graph, 1);
	}

	@Test
	public function test_in_two_node_graph_path_should_be_generated_with_length_2(){
		_source.addArc(_target);

		var finder = new AStar(_graph);
		_path = finder.find(_graph, _source, _target);
		Assert.areEqual(2, _path.size());
	}

	@Test
	public function test_in_three_node_graph_path_should_be_generated_with_length_3(){
		var between = new Waypoint<Int>(_graph, 1);

		 _source.addArc(between);
		 between.addArc(_target);

		var finder = new AStar(_graph);
		_path = finder.find(_graph, _source, _target);
		Assert.areEqual(3, _path.size());
	}

	@Test
	public function test_in_four_node_graph_with_one_side_node_path_should_be_generated_with_length_3(){
		var between  = new Waypoint<Int>(_graph, 100);
		var bad_path  = new Waypoint<Int>(_graph, 200);

		_source.addArc(between);
		_source.addArc(bad_path);
		between.addArc(_target);

		var finder = new AStar(_graph);
		_path = finder.find(_graph, _source, _target);
		Assert.areEqual(3, _path.size());
	}
}