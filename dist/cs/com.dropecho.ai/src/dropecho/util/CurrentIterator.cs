using haxe.root;

#pragma warning disable 109, 114, 219, 429, 168, 162
namespace dropecho.util {
	public class CurrentIterator<T> : global::haxe.lang.HxObject, global::dropecho.util.CurrentIterator {
		
		public CurrentIterator(global::haxe.lang.EmptyObject empty) {
		}
		
		
		public CurrentIterator(global::haxe.root.Array<T> array) {
			global::dropecho.util.CurrentIterator<object>.__hx_ctor_dropecho_util_CurrentIterator<T>(((global::dropecho.util.CurrentIterator<T>) (this) ), ((global::haxe.root.Array<T>) (array) ));
		}
		
		
		protected static void __hx_ctor_dropecho_util_CurrentIterator<T_c>(global::dropecho.util.CurrentIterator<T_c> __hx_this, global::haxe.root.Array<T_c> array) {
			__hx_this.array = array;
			__hx_this.i = 0;
		}
		
		
		public static object __hx_cast<T_c_c>(global::dropecho.util.CurrentIterator me) {
			return ( (( me != null )) ? (me.dropecho_util_CurrentIterator_cast<T_c_c>()) : default(object) );
		}
		
		
		public virtual object dropecho_util_CurrentIterator_cast<T_c>() {
			if (global::haxe.lang.Runtime.eq(typeof(T), typeof(T_c))) {
				return this;
			}
			
			global::dropecho.util.CurrentIterator<T_c> new_me = new global::dropecho.util.CurrentIterator<T_c>(((global::haxe.lang.EmptyObject) (global::haxe.lang.EmptyObject.EMPTY) ));
			global::haxe.root.Array<string> fields = global::haxe.root.Reflect.fields(this);
			int i = 0;
			while (( i < fields.length )) {
				string field = fields[i++];
				global::haxe.root.Reflect.setField(new_me, field, global::haxe.root.Reflect.field(this, field));
			}
			
			return new_me;
		}
		
		
		public global::haxe.root.Array<T> array;
		
		public int i;
		
		public virtual T next() {
			return this.array[this.i++];
		}
		
		
		public virtual bool hasNext() {
			unchecked {
				return ( this.i < ( this.array.length - 1 ) );
			}
		}
		
		
		public virtual T current() {
			return this.array[this.i];
		}
		
		
		public virtual void reset() {
			this.i = 0;
		}
		
		
		public override double __hx_setField_f(string field, int hash, double @value, bool handleProperties) {
			unchecked {
				switch (hash) {
					case 105:
					{
						this.i = ((int) (@value) );
						return @value;
					}
					
					
					default:
					{
						return base.__hx_setField_f(field, hash, @value, handleProperties);
					}
					
				}
				
			}
		}
		
		
		public override object __hx_setField(string field, int hash, object @value, bool handleProperties) {
			unchecked {
				switch (hash) {
					case 105:
					{
						this.i = ((int) (global::haxe.lang.Runtime.toInt(@value)) );
						return @value;
					}
					
					
					case 630156697:
					{
						this.array = ((global::haxe.root.Array<T>) (global::haxe.root.Array<object>.__hx_cast<T>(((global::haxe.root.Array) (@value) ))) );
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
					case 1724402127:
					{
						return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "reset", 1724402127)) );
					}
					
					
					case 1273207865:
					{
						return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "current", 1273207865)) );
					}
					
					
					case 407283053:
					{
						return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "hasNext", 407283053)) );
					}
					
					
					case 1224901875:
					{
						return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "next", 1224901875)) );
					}
					
					
					case 105:
					{
						return this.i;
					}
					
					
					case 630156697:
					{
						return this.array;
					}
					
					
					default:
					{
						return base.__hx_getField(field, hash, throwErrors, isCheck, handleProperties);
					}
					
				}
				
			}
		}
		
		
		public override double __hx_getField_f(string field, int hash, bool throwErrors, bool handleProperties) {
			unchecked {
				switch (hash) {
					case 105:
					{
						return ((double) (this.i) );
					}
					
					
					default:
					{
						return base.__hx_getField_f(field, hash, throwErrors, handleProperties);
					}
					
				}
				
			}
		}
		
		
		public override object __hx_invokeField(string field, int hash, object[] dynargs) {
			unchecked {
				switch (hash) {
					case 1724402127:
					{
						this.reset();
						break;
					}
					
					
					case 1273207865:
					{
						return this.current();
					}
					
					
					case 407283053:
					{
						return this.hasNext();
					}
					
					
					case 1224901875:
					{
						return this.next();
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
			baseArr.push("i");
			baseArr.push("array");
			base.__hx_getFields(baseArr);
		}
		
		
	}
}



#pragma warning disable 109, 114, 219, 429, 168, 162
namespace dropecho.util {
	[global::haxe.lang.GenericInterface(typeof(global::dropecho.util.CurrentIterator<object>))]
	public interface CurrentIterator : global::haxe.lang.IHxObject, global::haxe.lang.IGenericObject {
		
		object dropecho_util_CurrentIterator_cast<T_c>();
		
		bool hasNext();
		
		void reset();
		
	}
}


