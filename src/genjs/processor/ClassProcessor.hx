package genjs.processor;

import haxe.Template;
import haxe.macro.Type;
import haxe.macro.JSGenApi;
import genjs.processor.Dependency;

using StringTools;
using tink.MacroApi;

class ClassProcessor {
	static var cache = new Map();
	
	public static function process(api:JSGenApi, id:String, cls:ClassType):ProcessedClass {
		if(!cache.exists(id)) {
			
			var ids = [id];
			var stubs = [];
			var dependencies = [];
			
			function checkStubDependency(name:String, code:String) {
				if(stubs.indexOf(name) != -1) return;
				if(code.indexOf('$$$name') != -1) stubs.push(name);
			}
			
			api.setCurrentClass(cls);
			api.setTypeAccessor(function(type) {
				if(stubs.indexOf('import') == -1) stubs.push('import');
				var id:TypeID = type.getID();
				if(ids.indexOf(id) == -1) {
					ids.push(id);
					dependencies.push(DType(type));
				}
				return '::' + id.asTemplateHolder() + '::';
			});
			
			function constructField(f:ClassField, isStatic:Bool) {
				var code = switch f.expr() {
					case null: null;
					case e: 
						var code = api.generateStatement(e);
						checkStubDependency('iterator', code);
						checkStubDependency('bind', code);
						checkStubDependency('extend', code);
						code;
				}
				
				return {
					field: f,
					isStatic: isStatic,
					code: code,
					template: code == null ? null : new Template(code),
				}
			}
			
			var fields = cls.fields.get().map(constructField.bind(_, false));
			var statics = cls.statics.get().map(constructField.bind(_, true));
			var constructor = switch cls.constructor {
				case null: null;
				case ctor: constructField(ctor.get(), false);
			}
			
			if(cls.superClass != null) stubs.push('extend');
			
			cache[id] = {
				id: id,
				type: cls,
				fields: fields.concat(statics),
				constructor: constructor,
				dependencies: stubs.map(DStub).concat(dependencies),
			}
		}
		return cache[id];
	}
}