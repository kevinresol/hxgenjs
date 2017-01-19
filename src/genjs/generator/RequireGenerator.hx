package genjs.generator;

import haxe.macro.Type;
import haxe.macro.JSGenApi;
import genjs.processor.*;

using haxe.io.Path;
using tink.MacroApi;

class RequireGenerator {
	public static function generate(api:JSGenApi, currentPath:String, dependencies:Array<Dependency>) {
		var prefix = './';
		if(currentPath != '')
			prefix += [for(i in 0...currentPath.split('/').length) '..'].join('/') + '/';
			
		var code = [];
		for(dep in dependencies) {
			switch dep {
				case DType(type):
					var isExtern = false;
					var id:TypeID = switch TypeProcessor.flatten(type) {
						case Some(FClass(id, cls)):
							isExtern = cls.isExtern;
							id;
						case Some(FEnum(id, enm)):
							id;
						default:
							continue;
					}
					var path = api.quoteString(prefix + id.asFilePath());
					var require = 'require($path)';
					if(isExtern) require = '$$import($require)';
					code.push('var ${id.asVarSafeName()} = $require;');
					
				case DStub(name):
					var path = api.quoteString(prefix + name + '_stub');
					code.push('var $$$name = require($path).default;');
			}
		}
		return code.join('\n');
	}
}