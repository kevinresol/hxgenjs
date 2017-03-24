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
					switch TypeProcessor.flatten(type) {
						case Some(FClass(id, cls)):
							var cls = ClassProcessor.process(api, id, cls);
							var varname = id.asVarSafeName();
							switch cls.externType {
								case None:
									var path = api.quoteString(prefix + id.asFilePath());
									code.push('var $varname = require($path);');
								case Require(p, false):
									var path = api.quoteString(p[0]);
									code.push('var $varname = require($path);');
								case Require(p, true):
									var path = api.quoteString(p[0]);
									code.push('var $varname = $$import(require($path));');
								case Native(_) | CoreApi | Global: 
									// do nothing
							}
							varname = id.asVarSafeName();
							
						case Some(FEnum(id, enm)):
							var path = api.quoteString(prefix + id.asFilePath());
							var varname = id.asVarSafeName();
							code.push('var $varname = require($path);');
							
						default:
							continue;
							
					}
					
				case DStub(name):
					var path = api.quoteString(prefix + name + '_stub');
					code.push('var $$$name = require($path).default;');
			}
		}
		return code.join('\n');
	}
}