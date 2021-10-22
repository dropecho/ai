using haxe.root;

#pragma warning disable 109, 114, 219, 429, 168, 162
namespace dropecho.ai.bt {
	public class BehaviorTree : global::haxe.lang.HxObject, global::dropecho.ai.bt.node.Node {
		
		public BehaviorTree(global::haxe.lang.EmptyObject empty) {
		}
		
		
		public BehaviorTree(global::dropecho.ai.bt.node.Node root) {
			global::dropecho.ai.bt.BehaviorTree.__hx_ctor_dropecho_ai_bt_BehaviorTree(this, root);
		}
		
		
		protected static void __hx_ctor_dropecho_ai_bt_BehaviorTree(global::dropecho.ai.bt.BehaviorTree __hx_this, global::dropecho.ai.bt.node.Node root) {
			if (( root == null )) {
				throw ((global::System.Exception) (global::haxe.Exception.thrown("Root cannot be null")) );
			}
			
			__hx_this.child = root;
		}
		
		
		public virtual object dropecho_ai_bt_node_IExecutable_cast<T_c>() {
			return this;
		}
		
		
		public global::dropecho.ai.bt.node.Node child;
		
		public global::dropecho.ai.Blackboard context;
		
		public virtual void init(global::dropecho.ai.Blackboard context) {
			if (( context == null )) {
				context = new global::dropecho.ai.Blackboard();
			}
			
			this.context = context;
			this.child.init(this.context);
		}
		
		
		public virtual int execute() {
			return this.child.execute();
		}
		
		
		public override object __hx_setField(string field, int hash, object @value, bool handleProperties) {
			unchecked {
				switch (hash) {
					case 427267567:
					{
						this.context = ((global::dropecho.ai.Blackboard) (@value) );
						return @value;
					}
					
					
					case 1169795484:
					{
						this.child = ((global::dropecho.ai.bt.node.Node) (@value) );
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
					
					
					case 1169795484:
					{
						return this.child;
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
			baseArr.push("child");
			base.__hx_getFields(baseArr);
		}
		
		
	}
}


