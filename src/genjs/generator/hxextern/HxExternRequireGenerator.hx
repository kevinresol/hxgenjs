package genjs.generator.hxextern;

import haxe.macro.Type;
import haxe.macro.JSGenApi;
import genjs.processor.*;
import genjs.generator.*;

using haxe.io.Path;
using tink.MacroApi;
using StringTools;

class HxExternRequireGenerator implements IRequireGenerator {
	public function new() {}
	public function generate(api:JSGenApi, currentPath:String, dependencies:Array<Dependency>) {
		var code = [];
		for(dep in dependencies) {
			switch dep {
				case DType(type):
					switch TypeProcessor.flatten(type) {
						case Some(FClass(id, cls)):
							var cls = ClassProcessor.process(api, id, cls);
							// TODO: Fix paths like "js._Boot.HaxeError"
							var packageName = cls.id.split (".").slice (0, -1).join (".");
							if (packageName == packageName.toLowerCase ())
								switch cls.externType {
									case None:
										// var path = api.quoteString(prefix + id.asFilePath());
										// code.push('function $varname() {return require($path);}');
										if (id == "haxe.IMap") id = "haxe.Constraints.IMap";
										code.push('import $id;');
									case Require(p, false):
										// var path = p[0];
										// if(path.startsWith('.')) path = prefix + path;
										// path = api.quoteString(path);
										// code.push('function $varname() {return require($path);}');
										code.push('import $id;');
									case Require(p, true):
										// var path = p[0];
										// if(path.startsWith('.')) path = prefix + path;
										// path = api.quoteString(path);
										// code.push('function $varname() {return $$import(require($path));}');
									case Native(_) | CoreApi | Global: 
										// do nothing
								}
							
						case Some(FEnum(id, enm)):
							var packageName = id.split (".").slice (0, -1).join (".");
							if (packageName == packageName.toLowerCase ())
								code.push('import $id;');
							
						default:
							continue;
							
					}
					
				case DStub(name):
					continue;
			}
		}
		return code.join('\n');
	}
}