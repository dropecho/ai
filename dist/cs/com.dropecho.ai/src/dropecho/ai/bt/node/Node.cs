using haxe.root;

#pragma warning disable 109, 114, 219, 429, 168, 162
namespace dropecho.ai.bt.node {
	public interface IExecutable<T> : global::haxe.lang.IHxObject, global::dropecho.ai.bt.node.IExecutable {
		
		T execute();
		
	}
	public class IExecutable__Statics_{
		public static object __hx_cast<T_c_c>(global::dropecho.ai.bt.node.IExecutable me) {
			#line 6 "/home/vantreeseba/code/dropecho/ai/src/dropecho/ai/bt/node/Node.hx"
			return ( (( me != null )) ? (me.dropecho_ai_bt_node_IExecutable_cast<T_c_c>()) : default(object) );
		}
		#line default
		
	}
}



#pragma warning disable 109, 114, 219, 429, 168, 162
namespace dropecho.ai.bt.node {
	[global::haxe.lang.GenericInterface(typeof(global::dropecho.ai.bt.node.IExecutable<object>))]
	public interface IExecutable : global::haxe.lang.IHxObject, global::haxe.lang.IGenericObject {
		
		object dropecho_ai_bt_node_IExecutable_cast<T_c>();
		
		void init(global::dropecho.ai.Blackboard context);
		
	}
}



#pragma warning disable 109, 114, 219, 429, 168, 162
namespace dropecho.ai.bt.node {
	public interface Node : global::haxe.lang.IHxObject, global::dropecho.ai.bt.node.IExecutable<int> {
		
	}
}


