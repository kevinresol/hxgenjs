package genjs.processor;

import haxe.Template;
import haxe.macro.Type;
import haxe.macro.JSGenApi;
import genjs.processor.Dependency;

using StringTools;
using tink.MacroApi;

class MainProcessor {
	
	public static function process(api:JSGenApi):ProcessedMain {
		var ids = [];
		var stubs = [];
		var dependencies = [];
		
		api.setTypeAccessor(function(type) {
			if(stubs.indexOf('import') == -1) stubs.push('import');
			var id:TypeID = type.getID();
			if(ids.indexOf(id) == -1) {
				ids.push(id);
				dependencies.push(DType(type));
			}
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
				checkStubDependency('bind', code);
				checkStubDependency('extend', code);
				code;
		}
		
		return {
			code: code,
			template: code == null ? null : new Template(code),
			dependencies: stubs.map(DStub).concat(dependencies),
		}
	}
}