package genjs.processor;

import haxe.Template;
import haxe.macro.Type;
import haxe.macro.JSGenApi;
import genjs.processor.Dependency;
import genjs.processor.TypeProcessor;
import genjs.processor.Expose;

using StringTools;
#if tink_macro
using tink.MacroApi;
#else
using genjs._util.MacroUtil;
#end
using Lambda;

class MainProcessor {
	
	public static function process(api:JSGenApi, allTypes:Array<ProcessResult>):ProcessedMain {
		var ids = [];
		var stubs = [];
		var dependencies = new Map();
		var exposes = new Map();
		
		api.setTypeAccessor(function(type) {
			if(stubs.indexOf('import') == -1) stubs.push('import');
			var id:TypeID = type.getID();
			dependencies.set(id, DType(type));
			return '::' + id.asTemplateHolder() + '::';
		});
		
		function checkStubDependency(name:String, code:String) {
			if(stubs.indexOf(name) != -1) return;
			if(code.indexOf('$$$name') != -1) stubs.push(name);
		}
		
		var code = switch api.main {
			case null: null;
			case main:
				var code = api.generateStatement(main);
				checkStubDependency('iterator', code);
				checkStubDependency('getIterator', code);
				checkStubDependency('bind', code);
				checkStubDependency('extend', code);
				code;
		}
		
		for(type in allTypes) {
			switch type {
				case PClass(cls):
					// expose class
					switch cls.expose {
						case Some(name):
							exposes.set(name, EClass(cls));
							dependencies.set(cls.id, DType(cls.ref));
						default:
					}
					
					// expose static fields
					for(field in cls.fields) {
						switch field.expose {
							case Some(name):
								exposes.set(name, EClassField(cls, field));
								dependencies.set(cls.id, DType(cls.ref));
							default:
						}
					}
					
				default:
			}
		}
		
		return {
			code: code,
			template: code == null ? null : new Template(code),
			dependencies: stubs.map(DStub).concat([for(d in dependencies) d]),
			exposes: exposes,
		}
	}
}