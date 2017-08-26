package genjs.generator;

import haxe.ds.Option;
import haxe.macro.JSGenApi;
import genjs.processor.*;

using tink.MacroApi;
using haxe.io.Path;
using StringTools;
using genjs.template.CodeTools;

class ClassGenerator {
	public static function generate(api:JSGenApi, c:ProcessedClass) {
		
		if((c.constructor == null || c.constructor.code == null) && c.fields.length == 0)
			return None;
		if(c.type.isExtern)
			return None;
		
		var filepath = c.id.asFilePath() + '.js';
		var name = c.type.name;
		
		var data = {};
		Reflect.setField(data, 'className', name);
		Reflect.setField(data, c.id.asTemplateHolder(), name);
		for(dependency in c.dependencies) switch dependency {
			case DType(TypeProcessor.process(api, _) => Some(PClass(c))):
				Reflect.setField(data, c.id.asTemplateHolder(), c.id.asAccessName(c.externType));
			
			case DType(TypeProcessor.process(api, _) => Some(PEnum(e))): 
				Reflect.setField(data, e.id.asTemplateHolder(), e.id.asAccessName());
				
			default:
		}
		var requireStatements = RequireGenerator.generate(api, filepath.directory(), c.dependencies);
		
		
		var ctor = 'var $name = ' + switch c.constructor {
			case null | {template: null}: 'function(){}';
			case {template: template}: template.execute(data);
		}
		
		// Fields
		var fields = [];
		for(field in c.fields.filter(function(f) return !f.isStatic)) {
			switch FieldGenerator.generate(api, field, data) {
				case Some(v): fields.push(v);
				case None:
			}
		}
		var fields = '{\n' + fields.join(',\n').indent(1) + '\n}';
		
		// Statics
		var statics = [];
		for(field in c.fields.filter(function(f) return f.isStatic)) {
			switch FieldGenerator.generate(api, field, data) {
				case Some(v): statics.push(v);
				case None:
			}
		}
		var statics = statics.join('\n');
		
		// Meta
		var meta = ['$name.__name__ = true;'];
		switch c.type.superClass {
			case null:
				meta.push('$name.prototype = $fields;');
			case {t: sc}:
				var sc = ClassProcessor.process(api, sc.toString(), sc.get());
				var scname = sc.id.asVarSafeName();
				meta.push('$name.__super__ = $scname;');
				meta.push('$name.prototype = $$extend(${sc.id.asAccessName(sc.externType)}.prototype, $fields);');
		}
		
		// __init__
		var init = 
			if(c.init != null) c.init.template.execute(data) + ';';
			else '';
		
		
		// var code = '';
		// for(field in c.fields) if(field.template != null) code += '\n' + field.template.execute({});
		// for(field in c.statics) if(field.template != null) code += '\n' + field.template.execute({});
		// if(code != '') {
		// 	trace(filepath);
		// 	trace(code);
		// }
		return Some([
			'// Class: ${c.id}',
			'var $$global = typeof window != "undefined" ? window : typeof global != "undefined" ? global : typeof self != "undefined" ? self : this',
			'$$global.Object.defineProperty(exports, "__esModule", {value: true});',
			'var __map_reserved = {};', // TODO: add only if needed
			'// Imports',
			requireStatements,
			'// Definition',
			ctor,
			meta.join('\n'),
			init,
			statics,
			'exports.default = $name;',
		].join('\n\n'));
	}
}