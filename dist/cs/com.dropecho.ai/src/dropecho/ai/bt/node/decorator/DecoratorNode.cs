using haxe.root;

#pragma warning disable 109, 114, 219, 429, 168, 162
namespace dropecho.ai.bt.node.decorator {
	public class DecoratorNode : global::haxe.lang.HxObject, global::dropecho.ai.bt.node.Node {
		
		public DecoratorNode(global::haxe.lang.EmptyObject empty) {
		}
		
		
		public DecoratorNode(global::dropecho.ai.bt.node.Node child) {
			global::dropecho.ai.bt.node.decorator.DecoratorNode.__hx_ctor_dropecho_ai_bt_node_decorator_DecoratorNode(this, child);
		}
		
		
		protected static void __hx_ctor_dropecho_ai_bt_node_decorator_DecoratorNode(global::dropecho.ai.bt.node.decorator.DecoratorNode __hx_this, global::dropecho.ai.bt.node.Node child) {
			__hx_this.child = child;
		}
		
		
		public virtual object dropecho_ai_bt_node_IExecutable_cast<T_c>() {
			return this;
		}
		
		
		public global::dropecho.ai.bt.node.Node child;
		
		public global::dropecho.ai.Blackboard context;
		
		public virtual void init(global::dropecho.ai.Blackboard context) {
			this.context = context;
			if (( ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this.child, "init", 1169898256)) ) != null )) {
				this.child.init(context);
			}
			
		}
		
		
		public virtual int execute() {
			throw new global::dropecho.util.NotImplementedException();
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


