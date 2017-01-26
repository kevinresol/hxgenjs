package genjs.processor;

import haxe.Template;
import haxe.macro.Type;
import haxe.macro.JSGenApi;
import genjs.template.*;

class EnumConstructorProcessor {
	public static function process(api:JSGenApi, ctor:EnumField) {
		var ident = '::enumName::.${ctor.name}';
		var template = switch(ctor.type) {
			case TFun(args, _):
				var sargs = args.map(function(a) return a.name).join(',');
				'$ident = function($sargs) { var $$x = ["${ctor.name}",${ctor.index},$sargs]; $$x.__enum__ = ::enumName::; $$x.toString = $$estr; return $$x; }';
			default:
				'$ident = [${api.quoteString(ctor.name)},${ctor.index}];\n' +
				'$ident.toString = $$estr;\n' +
				'$ident.__enum__ = ::enumName::;\n';
		}
		return {
			field: ctor,
			template: new EnumConstructorTemplate(template),
		}
	}
}
