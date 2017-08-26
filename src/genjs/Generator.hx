package genjs;

import haxe.DynamicAccess;
import haxe.macro.Compiler;
import haxe.macro.Context;
import genjs.processor.*;
import genjs.generator.*;
import sys.io.File;
import sys.FileSystem;

using haxe.io.Path;
using StringTools;
using tink.MacroApi;

class Generator {
	public static var debug = false;
	#if macro
	public static function use() {
		Context.onMacroContextReused(function() return false);
		Compiler.setCustomJSGenerator(function(api) {
			var path = api.outputFile.directory().addTrailingSlash();
			var stubs = new DynamicAccess();
			var typeIds = new DynamicAccess();
			var types = [];
			var data = {};
			
			// process types
			for(type in api.types) {
				switch TypeProcessor.process(api, type) {
					case Some(v):
						types.push(v);
						switch v {
							case PClass({dependencies: d}) | PEnum({dependencies: d}):
								for(d in d) switch d {
									case DType(t): typeIds.set(t.getID(), true);
									case DStub(n): stubs.set(n, true);
								}
						}
					case None:
				}
			}
			
			// process entry point
			var main = MainProcessor.process(api);
			for(d in main.dependencies) switch d {
				case DType(t): typeIds.set(t.getID(), true);
				default:
			}
			
			// prepare type accessors
			for(typeId in typeIds.keys()) {
				var id:TypeID = typeId;
				Reflect.setField(data, id.asTemplateHolder(), id.asAccessName());
			}
			
			// generate types
			for(type in types) {
				var code = switch type {
					case null: 
					case PClass(c): 
						switch ClassGenerator.generate(api, c) {
							case Some(code): write(path + c.id.asFilePath() + '.js', code);
							case None:
						}
					case PEnum(e): 
						switch EnumGenerator.generate(api, e) {
							case Some(code): write(path + e.id.asFilePath() + '.js', code);
							case None:
						}
				}
			}
			
			// generate entry point
			switch MainGenerator.generate(api, main, data) {
				case None:
				case Some(code): write(api.outputFile, code);
			}
			
			// copy stubs
			for(stub in stubs.keys()) {
				var name = stub + '_stub.js';
				File.copy(Context.resolvePath('stub/$name'), path + name);
			}
		});
	}
	static function write(path:String, content:String) {
		var dir = path.directory();
		if(!FileSystem.exists(dir)) FileSystem.createDirectory(dir);
		File.saveContent(path, content);
	}
	#end
}