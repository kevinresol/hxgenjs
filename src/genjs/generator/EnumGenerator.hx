package genjs.generator;

import haxe.ds.Option;
import haxe.macro.JSGenApi;
import genjs.processor.*;

using tink.MacroApi;
using haxe.io.Path;
using StringTools;
using genjs.template.CodeTools;

class EnumGenerator {
	public static function generate(api:JSGenApi, e:ProcessedEnum) {
		
		var filepath = e.id.asFilePath() + '.js';
		var name = e.type.name;
		
		var data = {};
		Reflect.setField(data, 'enumName', name);
		Reflect.setField(data, name, name);
		for(dependency in e.dependencies) switch dependency {
			case DType(type): 
				var id:TypeID = type.getID();
				Reflect.setField(data, id.asTemplateHolder(), id.asVarSafeName() + '.default');
			default:
		}
		var requireStatements = RequireGenerator.generate(api, filepath.directory(), e.dependencies);
		
		var ename = e.id.split('.').map(api.quoteString).join(',');
		var constructs = e.type.names.map(api.quoteString).join(',');
		var ctor = 'var $name = { __ename__: [$ename], __constructs__: [$constructs] }';
		var fields = [for(c in e.constructors) c.template.execute(name)];
		
		return Some([
			'// Enum: ${e.id}',
			'Object.defineProperty(exports, "__esModule", {value: true});',
			'// Imports',
			requireStatements,
			'// Definition',
			ctor,
			fields.join('\n'),
			'exports.default = $name;',
		].join('\n\n'));
	}
}