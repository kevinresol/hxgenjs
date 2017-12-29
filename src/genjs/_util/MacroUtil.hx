package genjs._util;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class MacroUtil {
	
  static public function getID(t:Type, ?reduced = true)
    return
      if (reduced)
        getID(reduce(t), false);
      else
        switch (t) {
          case TAbstract(t, _): t.toString();
          case TInst(t, _): t.toString();
          case TEnum(t, _): t.toString();
          case TType(t, _): t.toString();
          default: null;
        }

  static public inline function reduce(type:Type, ?once)
    return Context.follow(type, once);

}