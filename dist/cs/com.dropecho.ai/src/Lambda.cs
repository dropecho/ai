using haxe.root;

#pragma warning disable 109, 114, 219, 429, 168, 162
namespace haxe.root {
	public class Lambda : global::haxe.lang.HxObject {
		
		public Lambda(global::haxe.lang.EmptyObject empty) {
		}
		
		
		public Lambda() {
			#line 39 "/usr/share/haxe/std/Lambda.hx"
			global::haxe.root.Lambda.__hx_ctor__Lambda(this);
		}
		#line default
		
		protected static void __hx_ctor__Lambda(global::haxe.root.Lambda __hx_this) {
		}
		
		
		public static void iter<A>(object it, global::haxe.lang.Function f) {
			#line 157 "/usr/share/haxe/std/Lambda.hx"
			object x = ((object) (global::haxe.lang.Runtime.callField(it, "iterator", 328878574, null)) );
			#line 157 "/usr/share/haxe/std/Lambda.hx"
			while (global::haxe.lang.Runtime.toBool(global::haxe.lang.Runtime.callField(x, "hasNext", 407283053, null))) {
				#line 157 "/usr/share/haxe/std/Lambda.hx"
				A x1 = global::haxe.lang.Runtime.genericCast<A>(global::haxe.lang.Runtime.callField(x, "next", 1224901875, null));
				f.__hx_invoke1_o(default(double), x1);
			}
			
		}
		#line default
		
	}
}


