package genjs;

import haxe.DynamicAccess;
import haxe.macro.Compiler;
import haxe.macro.Context;
import genjs.processor.*;
import genjs.generator.*;
#if hxextern
import genjs.generator.hxextern.*;
#end
#if tsextern
import genjs.generator.tsextern.*;
#end
import sys.io.File;
import sys.FileSystem;

using haxe.io.Path;
using StringTools;
using tink.MacroApi;

class Generator {
	public static var debug = false;
	
	public static var generators = [
		#if (genjs != "no")
		{
			classGenerator: ClassGenerator,
			enumGenerator: EnumGenerator,
			fileExtension: '.js',
		},
		#end
		
		#if hxextern
		{
			classGenerator: HxExternClassGenerator,
			enumGenerator: HxExternEnumGenerator,
			fileExtension: '.hx',
		},
		#end
		
		#if tsextern
		{
			classGenerator: TSExternClassGenerator,
			enumGenerator: TSExternEnumGenerator,
			fileExtension: '.d.ts',
		},
		#end
	];
	
	#if macro
	public static function use() {
		if (!Context.defined('js')) return;
		Context.onMacroContextReused(function() return false);
		
		// WORKAROUND: https://github.com/HaxeFoundation/haxe/issues/6539
		var folder = directory(Compiler.getOutput());
		if(!FileSystem.exists(folder)) FileSystem.createDirectory(folder);
		
		Compiler.setCustomJSGenerator(function(api) {
			var path = directory(api.outputFile).addTrailingSlash();
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
			var main = MainProcessor.process(api, types);
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
			for(type in types) for(config in generators) {
				switch type {
					case null: 
					case PClass(c): 
						switch config.classGenerator.generate(api, c) {
							case Some(code): write(path + c.id.asFilePath() + config.fileExtension, code);
							case None:
						}
					case PEnum(e): 
						switch config.enumGenerator.generate(api, e) {
							case Some(code): write(path + e.id.asFilePath() + config.fileExtension, code);
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
		var dir = directory(path);
		if(!FileSystem.exists(dir)) FileSystem.createDirectory(dir);
		File.saveContent(path, content);
	}
	
	static function directory(path:String) {
		return switch path.directory() {
			case '': '.';
			case v: v;
		}
	}
	#end
}