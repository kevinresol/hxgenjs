package genjs.processor;

import haxe.Template;
import haxe.macro.Type;
import haxe.macro.JSGenApi;
import genjs.processor.Dependency;
import genjs.processor.ExternType;

using StringTools;
#if tink_macro
using tink.MacroApi;
#else
using haxe.macro.ExprTools;
#end

class EnumProcessor {
	static var cache = new Map();
	
	public static function process(api:JSGenApi, id:String, enm:EnumType, ?ref:Type) {
		if(!cache.exists(id)) {
			if(ref == null) throw 'Type reference cannot be null when a class is processed for the first time';
			
			inline function m(name) return enm.meta.extract(name);
			var externType =
				if(!enm.isExtern) None
				else switch [m(':jsRequire'), m(':native'), m(':coreApi')] {
					case [[v], _, _]: 
						var params:Array<String> = v.params.map(function(e) return e.getValue());
						var isDefault = false;
						if(params[1] != null && params[1].startsWith('default')) {
							isDefault = true;
							params[1] = params[1].substr('default'.length);
							if(params[1].startsWith('.')) params[1] = params[1].substr(1);
							if(params[1] == '') params.splice(1, 1);
						}
						Require(params, isDefault);
					case [_, [v], _]: Native(v.params[0].getValue());
					case [_, _, [v]]: CoreApi;
					default: Global;
				}
			
			cache[id] = {
				id: id,
				type: enm,
				ref: ref,
				externType: externType,
				constructors: [for(ctor in enm.constructs) EnumConstructorProcessor.process(api, ctor)],
				dependencies: [
					DStub('estr'),
					DStub(#if haxe4 'hxEnums' #else 'hxClasses' #end),
				],
			}
		}
		return cache[id];
	}
}
