package genjs.generator;

import haxe.ds.Option;
import haxe.macro.JSGenApi;
import genjs.processor.*;

#if tink_macro
using tink.MacroApi;
#else
using genjs._util.MacroUtil;
#end
using haxe.io.Path;
using StringTools;
using genjs.template.CodeTools;

class EnumGenerator implements IEnumGenerator {
	public function new() {}
	public function generate(api:JSGenApi, e:ProcessedEnum) {
		if(e.type.isExtern)
			return None;
			
		var filepath = e.id.asFilePath() + '.js';
		var name = e.type.name;
		
		var data = {};
		Reflect.setField(data, 'enumName', name);
		Reflect.setField(data, name, name);
		for(dependency in e.dependencies) switch dependency {
			case DType(TypeProcessor.process(api, _) => Some(PClass(c))):
				Reflect.setField(data, c.id.asTemplateHolder(), c.id.asAccessName(c.externType));
			
			case DType(TypeProcessor.process(api, _) => Some(PEnum(e))): 
				Reflect.setField(data, e.id.asTemplateHolder(), e.id.asAccessName(e.externType));
				
			default:
		}
		var requireStatements = new RequireGenerator().generate(api, filepath.directory(), e.dependencies);
		
		var ename = #if haxe4 '"${e.id}"' #else '[${e.id.split('.').map(api.quoteString).join(',')}]' #end;
		var constructs = e.type.names.map(api.quoteString).join(',');
		
		#if haxe4
		var code =
			'var $name = $$hxEnums[$ename] = { __ename__ : $ename, __constructs__ : [$constructs]\n' +
			[for(c in e.constructors) '  ' + c.template.execute(name)].join('\n') +
			'\n};';
		#else
		var code = 
			'var $name = $$hxClasses["${e.id}"] = { __ename__: $ename, __constructs__: [$constructs] }\n' +
			[for(c in e.constructors) c.template.execute(name)].join('\n');
		#end
		
		
		return Some([
			'// Enum: ${e.id}',
			'var $$global = typeof window != "undefined" ? window : typeof global != "undefined" ? global : typeof self != "undefined" ? self : this',
			'$$global.Object.defineProperty(exports, "__esModule", {value: true});',
			'// Imports',
			requireStatements,
			'// Definition',
			code,
			'exports.default = $name;',
		].join('\n\n'));
	}
}