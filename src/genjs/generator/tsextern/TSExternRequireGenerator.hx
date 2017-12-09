package genjs.generator.tsextern;

import haxe.macro.Type;
import haxe.macro.JSGenApi;
import genjs.processor.*;

using haxe.io.Path;
using tink.MacroApi;
using StringTools;

class TSExternRequireGenerator {
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
									code.push('import $varname from $path;');
								case Require(p, false):
									var path = p[0];
									if(path.startsWith('.')) path = prefix + path;
									path = api.quoteString(path);
									code.push('import $varname from $path;');
								case Require(p, true):
									var path = p[0];
									if(path.startsWith('.')) path = prefix + path;
									path = api.quoteString(path);
									code.push('import $varname from $path;');
								case Native(_) | CoreApi | Global: 
									// do nothing
							}
							varname = id.asVarSafeName();
							
						case Some(FEnum(id, enm)):
							var path = api.quoteString(prefix + id.asFilePath());
							var varname = id.asVarSafeName();
							code.push('import $varname from $path;');
							
						default:
							continue;
							
					}
					
				case DStub(name):
					//var path = api.quoteString(prefix + name + '_stub');
					//code.push('var $$$name = require($path).default;');
			}
		}
		return code.join('\n');
	}
}