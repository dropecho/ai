using haxe.root;

#pragma warning disable 109, 114, 219, 429, 168, 162
namespace dropecho.ai.bt.node.composite {
	public class CompositeNode : global::haxe.lang.HxObject, global::dropecho.ai.bt.node.Node {
		
		public CompositeNode(global::haxe.lang.EmptyObject empty) {
		}
		
		
		public CompositeNode(global::haxe.root.Array<object> children) {
			global::dropecho.ai.bt.node.composite.CompositeNode.__hx_ctor_dropecho_ai_bt_node_composite_CompositeNode(this, children);
		}
		
		
		protected static void __hx_ctor_dropecho_ai_bt_node_composite_CompositeNode(global::dropecho.ai.bt.node.composite.CompositeNode __hx_this, global::haxe.root.Array<object> children) {
			__hx_this.children = children;
			__hx_this.childIterator = new global::dropecho.util.CurrentIterator<object>(((global::haxe.root.Array<object>) (children) ));
		}
		
		
		public virtual object dropecho_ai_bt_node_IExecutable_cast<T_c>() {
			return this;
		}
		
		
		public global::haxe.root.Array<object> children;
		
		public global::dropecho.util.CurrentIterator<object> childIterator;
		
		public global::dropecho.ai.Blackboard context;
		
		public virtual void init(global::dropecho.ai.Blackboard context) {
			this.context = context;
			global::haxe.lang.Function initChild = new global::dropecho.ai.bt.node.composite.CompositeNode_init_21__Fun(context);
			global::haxe.root.Lambda.iter<object>(((object) (this.children) ), ((global::haxe.lang.Function) (initChild) ));
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
					
					
					case 2104667050:
					{
						this.childIterator = ((global::dropecho.util.CurrentIterator<object>) (global::dropecho.util.CurrentIterator<object>.__hx_cast<object>(((global::dropecho.util.CurrentIterator) (@value) ))) );
						return @value;
					}
					
					
					case 1886001471:
					{
						this.children = ((global::haxe.root.Array<object>) (global::haxe.root.Array<object>.__hx_cast<object>(((global::haxe.root.Array) (@value) ))) );
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
					
					
					case 2104667050:
					{
						return this.childIterator;
					}
					
					
					case 1886001471:
					{
						return this.children;
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
			baseArr.push("childIterator");
			baseArr.push("children");
			base.__hx_getFields(baseArr);
		}
		
		
	}
}



#pragma warning disable 109, 114, 219, 429, 168, 162
namespace dropecho.ai.bt.node.composite {
	public class CompositeNode_init_21__Fun : global::haxe.lang.Function {
		
		public CompositeNode_init_21__Fun(global::dropecho.ai.Blackboard context) : base(1, 0) {
			this.context = context;
		}
		
		
		public override object __hx_invoke1_o(double __fn_float1, object __fn_dyn1) {
			object child = ( (( __fn_dyn1 == global::haxe.lang.Runtime.undefined )) ? (((object) (__fn_float1) )) : (((object) (__fn_dyn1) )) );
			if (( ((global::haxe.lang.Function) (global::haxe.lang.Runtime.getField(child, "init", 1169898256, true)) ) != null )) {
				object __temp_expr1 = ((object) (global::haxe.lang.Runtime.callField(child, "init", 1169898256, new object[]{this.context})) );
			}
			
			return null;
		}
		
		
		public global::dropecho.ai.Blackboard context;
		
	}
}


