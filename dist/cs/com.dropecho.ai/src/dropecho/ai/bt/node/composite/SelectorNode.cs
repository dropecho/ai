using haxe.root;

#pragma warning disable 109, 114, 219, 429, 168, 162
namespace dropecho.ai.bt.node.composite {
	public class SelectorNode : global::dropecho.ai.bt.node.composite.CompositeNode {
		
		public SelectorNode(global::haxe.lang.EmptyObject empty) : base(((global::haxe.lang.EmptyObject) (global::haxe.lang.EmptyObject.EMPTY) )) {
		}
		
		
		public SelectorNode(global::haxe.root.Array<object> children) : base(((global::haxe.lang.EmptyObject) (global::haxe.lang.EmptyObject.EMPTY) )) {
			global::dropecho.ai.bt.node.composite.SelectorNode.__hx_ctor_dropecho_ai_bt_node_composite_SelectorNode(this, children);
		}
		
		
		protected static void __hx_ctor_dropecho_ai_bt_node_composite_SelectorNode(global::dropecho.ai.bt.node.composite.SelectorNode __hx_this, global::haxe.root.Array<object> children) {
			global::dropecho.ai.bt.node.composite.CompositeNode.__hx_ctor_dropecho_ai_bt_node_composite_CompositeNode(__hx_this, children);
		}
		
		
		public override int execute() {
			unchecked {
				int status = ((global::dropecho.ai.bt.node.Node) (this.childIterator.current()) ).execute();
				if (( status == ((int) (0) ) )) {
					this.childIterator.reset();
					return ((int) (0) );
				}
				
				if (( status == ((int) (1) ) )) {
					if ( ! (this.childIterator.hasNext()) ) {
						this.childIterator.reset();
						return ((int) (1) );
					}
					
					global::dropecho.ai.bt.node.Node __temp_expr1 = ((global::dropecho.ai.bt.node.Node) (this.childIterator.next()) );
				}
				
				return ((int) (2) );
			}
		}
		
		
		public override object __hx_getField(string field, int hash, bool throwErrors, bool isCheck, bool handleProperties) {
			unchecked {
				switch (hash) {
					case 1275922997:
					{
						return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "execute", 1275922997)) );
					}
					
					
					default:
					{
						return base.__hx_getField(field, hash, throwErrors, isCheck, handleProperties);
					}
					
				}
				
			}
		}
		
		
	}
}


