package genjs.generator.hxextern;

import haxe.ds.Option;
import haxe.macro.JSGenApi;
import haxe.macro.Type;
import genjs.processor.*;
import genjs.generator.*;

#if tink_macro
using tink.MacroApi;
#end
using haxe.io.Path;
using haxe.macro.TypeTools;
using StringTools;
using genjs.template.CodeTools;

class HxExternClassGenerator implements IClassGenerator {
	public function new() {}
	public function generate(api:JSGenApi, c:ProcessedClass) {

		function superClassName(c:ClassType) 
			return switch c.superClass {
				case null: null;
				case {t: sc}:
					var sc = ClassProcessor.process(api, sc.toString(), sc.get());
					return sc.id.asAccessName(sc.externType);
			}		
		
		if((c.constructor == null || c.constructor.code == null) && c.fields.length == 0)
			return None;
		if(c.type.isExtern)
			return None;
		
		var filepath = c.id.asFilePath() + '.hx';
		var name = c.type.name;
		
		switch (c.id) {
			case "Type", "Reflect", "haxe.IMap", "js._Boot.HaxeError", "js.Boot", "Std", "HxOverrides", "haxe.StackItem", "List", "StringTools":
				return None;
		}
		
		// temp?
		if (StringTools.startsWith (c.id, "js.")) return None;
		if (StringTools.startsWith (c.id, "haxe.")) return None;
		if (StringTools.startsWith (filepath, "haxe/")) return None;
		
		var data = {};
		// Reflect.setField(data, 'className', name);
		// Reflect.setField(data, c.id.asTemplateHolder(), name);
		// for(dependency in c.dependencies) switch dependency {
		// 	case DType(TypeProcessor.process(api, _) => Some(PClass(c))):
		// 		Reflect.setField(data, c.id.asTemplateHolder(), c.id.asAccessName(c.externType));
			
		// 	case DType(TypeProcessor.process(api, _) => Some(PEnum(e))): 
		// 		Reflect.setField(data, e.id.asTemplateHolder(), e.id.asAccessName());
				
		// 	default:
		// }
		// HACK: Runtime type values from Std
		// Reflect.setField(data, 'Date', 'Date');
		// Reflect.setField(data, 'Int', '$$hxClasses["Int"]');
		// Reflect.setField(data, 'Dynamic', '$$hxClasses["Dynamic"]');
		// Reflect.setField(data, 'Float', '$$hxClasses["Float"]');
		// Reflect.setField(data, 'Bool', '$$hxClasses["Bool"]');
		// Reflect.setField(data, 'Class', '$$hxClasses["Class"]');
		// Reflect.setField(data, 'Enum', '$$hxClasses["Enum"]');
		// Reflect.setField(data, 'Void', '$$hxClasses["Void"]');
		
		var packageName = c.id.split (".").slice (0, -1).join (".");
		var packageDecl = "package" + (packageName != "" ? " " + packageName : "") + ";";
		
		var imports = new HxExternRequireGenerator().generate(api, filepath.directory(), c.dependencies);
		
		var require = '@:jsRequire("' + c.id.split (".").join ("/") + '", "default")';
		//var classStart = "extern class " + c.id.split (".").pop () + (c.type.superClass != null ? " extends " + c.type.superClass.t.get ().name : "") + " {";
		var className = c.id.split (".").pop ();
		var superClassName = null;
		var ignoreSuper = false;
		
		if (c.type.superClass != null) {
			var type = c.type.superClass.t.get ();
			// TODO: Fix for capitalized packages
			var pack = "";
			if (type.pack.length > 0) pack = type.pack.join (".");
			if (pack == pack.toLowerCase ()) {
				if (pack != "") superClassName = pack + "." + type.name;
				else superClassName = type.name;
			} else {
				ignoreSuper = true;
			}
		}
		
		var classStart = "extern class " + className + (superClassName != null ? " extends " + superClassName : "") + " implements Dynamic {";
		// var classStart = "extern class " + c.id.split (".").pop () + " extends Dynamic {";
		
		// var body = "function new ();";
		var body = "";
		
		var hasField;
		
		hasField = function (name:String, superClass:haxe.macro.Ref<haxe.macro.ClassType>) {
			if (ignoreSuper) return false;
			if (superClass != null) {
				var sc = superClass.get ();
				var fields = sc.fields.get();
				for (field in fields) {
					if (field.name == name) return true;
				}
				if (sc.superClass == null) return false;
				return hasField (name, sc.superClass.t);
			}
			return false;
		}
		
		// var convertParams = function (field:haxe.macro.ClassField) {
		// 	var params = "";
		// 	if (field != null && field.type != null) {
		// 		switch (field.type) {
		// 			case TFun(args, _):
		// 				for (arg in args) {
		// 					if (params != "") params += ", ";
		// 					params += (arg.opt ? "?" : "") + arg.name + ":" + "Dynamic"/*arg.t.toString ()*/;
		// 				}
		// 			default:
		// 		}
		// 	}
		// 	return params;
		// }
		
		var processField = function (field:haxe.macro.ClassField, isStatic:Bool) {
			var fieldCode = "";
			if (field != null && field.type != null) {
				switch (field.type) {
					case TFun(args, _):
						var params = "";
						var i = 0;
						for (arg in args) {
							if (params != "") params += ", ";
							var name = (arg.name != "" && arg.name != null) ? arg.name : "a" + (++i);
							params += (arg.opt ? "?" : "") + name + ":" + "Dynamic"/*arg.t.toString ()*/;
						}
						fieldCode = ((c.type.superClass != null && hasField(field.name, c.type.superClass.t)) ? "override " : "") + (isStatic? "static " : "") + "function " + field.name + "(" + params + ")" + (field.name != "new" ? ":Dynamic" : "") + ";";
					case TInst(t, _):
						fieldCode = (isStatic? "static " : "") + "var " + field.name + ":Dynamic;";
					case TAbstract(t, _):
						fieldCode = (isStatic? "static " : "") + "var " + field.name + ":Dynamic;";
					default:
				}
			}
			body += "\t" + fieldCode + "\n";
		}
		
		if (c.constructor != null) processField (c.constructor.field, false);
		for (field in c.fields) processField (field.field, field.isStatic);
		
		//var ctor = if (c.constructor != null) "function new(" + convertParams (c.constructor.field) + ");" else "";
		
		
		// TODO: Add fields
		
		// var ctor = 'var $name = ' + switch c.constructor {
		// 	case null | {template: null}: 'function(){}';
		// 	case {template: template}: template.execute(data);
		// }
		
		// var fields = [];
		// for(field in c.fields.filter(function(f) return !f.isStatic)) {
		// 	switch FieldGenerator.generate(api, field, data) {
		// 		case Some(v): fields.push(v);
		// 		case None:
		// 	}
		// }		
		// var fields = '{\n' + fields.join(',\n').indent(1) + '\n}';
		// // Statics
		// var staticFunctions = [];
		// var staticVariables = [];
		// for(field in c.fields.filter(function(f) return f.isStatic)) {
		// 	switch FieldGenerator.generate(api, field, data) {
		// 		case Some(v): (field.isFunction ? staticFunctions : staticVariables).push(v);
		// 		case None:
		// 	}
		// }
		
		// var statics = staticFunctions.join('\n') + '\n' + staticVariables.join('\n');
		
		// // Meta
		// var cname = c.id.split('.').map(api.quoteString).join(',');
		// var meta = ['$name.__name__ = [$cname];'];
		
		// switch c.type.interfaces {
		// 	case null | []: // do nothing;
		// 	case v:
		// 		var inames = [for(i in v) ClassProcessor.process(api, i.t.toString(), i.t.get()).id.asAccessName()];
		// 		meta.push('$name.__interfaces__ = [${inames.join(',')}];');
		// }
		
		var classEnd = "}";
		
		
		// var code = '';
		// for(field in c.fields) if(field.template != null) code += '\n' + field.template.execute({});
		// for(field in c.statics) if(field.template != null) code += '\n' + field.template.execute({});
		// if(code != '') {
		// 	trace(filepath);
		// 	trace(code);
		// }
		return Some([
			packageDecl,
			imports,
			require,
			classStart,
			// ctor,
			body,
			classEnd,
		].join('\n\n'));
	}
}