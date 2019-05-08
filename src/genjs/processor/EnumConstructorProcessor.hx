package genjs.processor;

import haxe.Template;
import haxe.macro.Type;
import haxe.macro.JSGenApi;
import genjs.template.*;
using haxe.macro.Tools;

class EnumConstructorProcessor {
	public static function process(api:JSGenApi, ctor:EnumField) {
		var ident = '::enumName::.${ctor.name}';
		var template = switch(ctor.type) {
			case TFun(args, ret):
				var sargs = args.map(function(a) return a.name).join(',');
				var sassign = args.map(function(a) return a.name + ':' + a.name).join(',');
				var snames = args.map(function(a) return '"${a.name}"').join(',');
				#if haxe4
				',${ctor.name}: ($$_=function($sargs) { return {_hx_index:${ctor.index},${sassign},__enum__:"${ret.toString()}",toString:$$estr}; },$$_.__params__ = [$snames],$$_)';
				#else
				'$ident = function($sargs) { var $$x = ["${ctor.name}",${ctor.index},$sargs]; $$x.__enum__ = ::enumName::; $$x.toString = $$estr; return $$x; }';
				#end
			default:
				#if haxe4
				',${ctor.name}: {_hx_index:${ctor.index},__enum__:"${ctor.type.toString()}",toString:$$estr}';
				#else
				'$ident = [${api.quoteString(ctor.name)},${ctor.index}];\n' +
				'$ident.toString = $$estr;\n' +
				'$ident.__enum__ = ::enumName::;\n';
				#end
		}
		return {
			field: ctor,
			template: new EnumConstructorTemplate(template),
		}
	}
}
