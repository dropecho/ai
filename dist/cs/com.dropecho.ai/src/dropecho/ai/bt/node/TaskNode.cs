using haxe.root;

#pragma warning disable 109, 114, 219, 429, 168, 162
namespace dropecho.ai.bt.node {
	public class TaskNode : global::haxe.lang.HxObject, global::dropecho.ai.bt.node.Node {
		
		public TaskNode(global::haxe.lang.EmptyObject empty) {
		}
		
		
		public TaskNode(string taskName) {
			global::dropecho.ai.bt.node.TaskNode.__hx_ctor_dropecho_ai_bt_node_TaskNode(this, taskName);
		}
		
		
		protected static void __hx_ctor_dropecho_ai_bt_node_TaskNode(global::dropecho.ai.bt.node.TaskNode __hx_this, string taskName) {
			__hx_this.action = global::dropecho.ai.TaskBank.@get(taskName);
		}
		
		
		public virtual object dropecho_ai_bt_node_IExecutable_cast<T_c>() {
			return this;
		}
		
		
		public global::haxe.lang.Function action;
		
		public global::dropecho.ai.Blackboard context;
		
		public virtual void init(global::dropecho.ai.Blackboard context) {
			this.context = context;
		}
		
		
		public virtual int execute() {
			return ((int) (this.action.__hx_invoke1_f(default(double), this.context)) );
		}
		
		
		public override object __hx_setField(string field, int hash, object @value, bool handleProperties) {
			unchecked {
				switch (hash) {
					case 427267567:
					{
						this.context = ((global::dropecho.ai.Blackboard) (@value) );
						return @value;
					}
					
					
					case 373701558:
					{
						this.action = ((global::haxe.lang.Function) (@value) );
						return @value;
					}
					
					
					default:
					{
						return base.__hx_setField(field, hash, @value, handleProperties);
					}
					
				}
				
			}
		}
		
		
		public override object __hx_getField(string field, int hash, bool throwErrors, bool isCheck, bool handleProperties) {
			unchecked {
				switch (hash) {
					case 1275922997:
					{
						return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "execute", 1275922997)) );
					}
					
					
					case 1169898256:
					{
						return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "init", 1169898256)) );
					}
					
					
					case 427267567:
					{
						return this.context;
					}
					
					
					case 373701558:
					{
						return this.action;
					}
					
					
					default:
					{
						return base.__hx_getField(field, hash, throwErrors, isCheck, handleProperties);
					}
					
				}
				
			}
		}
		
		
		public override object __hx_invokeField(string field, int hash, object[] dynargs) {
			unchecked {
				switch (hash) {
					case 1275922997:
					{
						return this.execute();
					}
					
					
					case 1169898256:
					{
						this.init(((global::dropecho.ai.Blackboard) (dynargs[0]) ));
						break;
					}
					
					
					default:
					{
						return base.__hx_invokeField(field, hash, dynargs);
					}
					
				}
				
				return null;
			}
		}
		
		
		public override void __hx_getFields(global::haxe.root.Array<string> baseArr) {
			baseArr.push("context");
			baseArr.push("action");
			base.__hx_getFields(baseArr);
		}
		
		
	}
}


