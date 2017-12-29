package genjs.generator.tsextern;

import haxe.ds.Option;
import haxe.macro.JSGenApi;
import genjs.processor.*;
import genjs.generator.*;

#if tink_macro
using tink.MacroApi;
#end
using haxe.io.Path;
using StringTools;
using genjs.template.CodeTools;

class TSExternEnumGenerator implements IEnumGenerator {
	public function new() {}
	public function generate(api:JSGenApi, e:ProcessedEnum) {
		
		var filepath = e.id.asFilePath() + '.d.ts';
		var name = e.type.name;
		
		// var data = {};
		// Reflect.setField(data, 'enumName', name);
		// Reflect.setField(data, name, name);
		// for(dependency in e.dependencies) switch dependency {
		// 	case DType(type): 
		// 		var id:TypeID = type.getID();
		// 		Reflect.setField(data, id.asTemplateHolder(), id.asVarSafeName() + '.default');
		// 	default:
		// }
		
		var packageName = e.id.split (".").slice (0, -1).join (".");
		var packageDecl = packageName != "" ? "declare namespace " + packageName + " {" : "";
		
		var imports = new TSExternRequireGenerator().generate(api, filepath.directory(), e.dependencies);
		
		// var enumStart = "extern enum " + e.id.split (".").pop () + " {";
		var enumName = e.id.split (".").pop ();
		var enumStart = "export enum " + e.id.split (".").pop () + " {";
		// var enumEnd = "}\n\n" + (packageDecl != "" ? "}\n\n" : "") + "export default " + e.id.split (".").pop () + ";";
		var enumEnd = "}\n\n" + (packageDecl != "" ? "}\n\nexport default " + packageName + "." + enumName : "export default " + enumName) + ";";
		
		// var ename = e.id.split('.').map(api.quoteString).join(',');
		// var constructs = e.type.names.map(api.quoteString).join(',');
		// var ctor = 'var $name = $$hxClasses["${e.id}"] = { __ename__: [$ename], __constructs__: [$constructs] }';
		// var fields = [for(c in e.constructors) c.template.execute(name)];
		
		return Some([
			imports,
			packageDecl,
			enumStart,
			enumEnd,
		].join('\n\n'));
	}
}