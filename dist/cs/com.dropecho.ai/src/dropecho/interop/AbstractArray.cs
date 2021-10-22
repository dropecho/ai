using haxe.root;

#pragma warning disable 109, 114, 219, 429, 168, 162
namespace dropecho.interop {
	public class CSListIterator<V> {
		
		public CSListIterator(global::System.Collections.Generic.List<V> list) {
			this.i = 0;
			this.c = list.Count;
			this.v = list.GetEnumerator();
		}
		
		
		public global::System.Collections.IEnumerator v;
		
		public int c;
		
		public int i;
		
		public virtual bool hasNext() {
			return ( this.i < this.c );
		}
		
		
		public virtual V next() {
			this.i++;
			this.v.MoveNext();
			return global::haxe.lang.Runtime.genericCast<V>(this.v.Current);
		}
		
		
	}
}



#pragma warning disable 109, 114, 219, 429, 168, 162
namespace dropecho.interop._AbstractArray {
	public sealed class AbstractArray_Impl_ {
		
		[global::System.ComponentModel.EditorBrowsable(global::System.ComponentModel.EditorBrowsableState.Never)]
		public static global::System.Collections.Generic.List<V> _new<V>(global::System.Collections.Generic.List<V> a) {
			global::System.Collections.Generic.List<V> this1 = null;
			if (( a != null )) {
				this1 = a;
			}
			else {
				this1 = new global::System.Collections.Generic.List<V>();
			}
			
			return ((global::System.Collections.Generic.List<V>) (this1) );
		}
		
		
	}
}


