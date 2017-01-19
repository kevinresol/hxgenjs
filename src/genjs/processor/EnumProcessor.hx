package genjs.processor;

import haxe.Template;
import haxe.macro.Type;
import haxe.macro.JSGenApi;
import genjs.processor.Dependency;

using StringTools;
using tink.MacroApi;

class EnumProcessor {
	static var cache = new Map();
	
	public static function process(api:JSGenApi, id:String, enm:EnumType) {
		if(!cache.exists(id)) {
			cache[id] = {
				id: id,
				type: enm,
				constructors: [for(ctor in enm.constructs) EnumConstructorProcessor.process(api, ctor)],
				dependencies: [DStub('estr')],
			}
		}
		return cache[id];
	}
}