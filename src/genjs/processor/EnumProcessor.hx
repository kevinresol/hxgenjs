package genjs.processor;

import haxe.Template;
import haxe.macro.Type;
import haxe.macro.JSGenApi;
import genjs.processor.Dependency;

using StringTools;
#if tink_macro
using tink.MacroApi;
#end

class EnumProcessor {
	static var cache = new Map();
	
	public static function process(api:JSGenApi, id:String, enm:EnumType, ?ref:Type) {
		if(!cache.exists(id)) {
			if(ref == null) throw 'Type reference cannot be null when a class is processed for the first time';
			cache[id] = {
				id: id,
				type: enm,
				ref: ref,
				constructors: [for(ctor in enm.constructs) EnumConstructorProcessor.process(api, ctor)],
				dependencies: [DStub('estr'), DStub('hxClasses')],
			}
		}
		return cache[id];
	}
}