using haxe.root;

#pragma warning disable 109, 114, 219, 429, 168, 162
namespace dropecho.ai {
	public class TaskBank : global::haxe.lang.HxObject {
		
		static TaskBank() {
			#line 11 "/home/vantreeseba/code/dropecho/ai/src/dropecho/ai/TaskBank.hx"
			global::dropecho.ai.TaskBank.tasks = global::dropecho.interop._AbstractMap.AbstractMap_Impl_._new<string, global::haxe.lang.Function>(default(global::System.Collections.Generic.IDictionary<string, global::haxe.lang.Function>));
		}
		#line default
		
		public TaskBank(global::haxe.lang.EmptyObject empty) {
		}
		
		
		public TaskBank() {
			#line 10 "/home/vantreeseba/code/dropecho/ai/src/dropecho/ai/TaskBank.hx"
			global::dropecho.ai.TaskBank.__hx_ctor_dropecho_ai_TaskBank(this);
		}
		#line default
		
		protected static void __hx_ctor_dropecho_ai_TaskBank(global::dropecho.ai.TaskBank __hx_this) {
		}
		
		
		public static global::System.Collections.Generic.IDictionary<string, global::haxe.lang.Function> tasks;
		
		public static void register(string name, global::haxe.lang.Function task) {
			#line 14 "/home/vantreeseba/code/dropecho/ai/src/dropecho/ai/TaskBank.hx"
			((global::System.Collections.Generic.IDictionary<string, global::haxe.lang.Function>) (global::dropecho.ai.TaskBank.tasks) )[((string) (name) )] = ((global::haxe.lang.Function) (task) );
		}
		#line default
		
		public static global::haxe.lang.Function @get(string name) {
			#line 18 "/home/vantreeseba/code/dropecho/ai/src/dropecho/ai/TaskBank.hx"
			global::System.Collections.Generic.IDictionary<string, global::haxe.lang.Function> this1 = global::dropecho.ai.TaskBank.tasks;
			#line 18 "/home/vantreeseba/code/dropecho/ai/src/dropecho/ai/TaskBank.hx"
			if ( ! (this1.ContainsKey(((string) (name) ))) ) {
				#line 18 "/home/vantreeseba/code/dropecho/ai/src/dropecho/ai/TaskBank.hx"
				throw ((global::System.Exception) (global::haxe.Exception.thrown(global::haxe.lang.Runtime.concat(global::haxe.lang.Runtime.concat("No key ", global::haxe.root.Std.@string(name)), " found in dictionary, try using .exists(key) to check first."))) );
			}
			
			#line 18 "/home/vantreeseba/code/dropecho/ai/src/dropecho/ai/TaskBank.hx"
			return this1[((string) (name) )];
		}
		#line default
		
	}
}


