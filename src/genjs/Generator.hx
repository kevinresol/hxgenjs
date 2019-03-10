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

using Lambda;
using haxe.io.Path;
using StringTools;
#if tink_macro
using tink.MacroApi;
#else
using genjs._util.MacroUtil;
#end

typedef Config = {
	mainGenerator:Null<IMainGenerator>,
	classGenerator:IClassGenerator,
	enumGenerator:IEnumGenerator,
	fileExtension:String,
	stubs:Bool,
}

class Generator {
	public static var debug = false;
	
	public static var generators:Array<Config> = [
		#if (!genjs || genjs != "no")
		{
			mainGenerator: new MainGenerator(),
			classGenerator: new ClassGenerator(),
			enumGenerator: new EnumGenerator(),
			fileExtension: '.js',
			stubs: true,
		},
		#end
		
		#if hxextern
		{
			mainGenerator: null,
			classGenerator: new HxExternClassGenerator(),
			enumGenerator: new HxExternEnumGenerator(),
			fileExtension: '.hx',
			stubs: false,
		},
		#end
		
		#if tsextern
		{
			mainGenerator: null,
			classGenerator: new TSExternClassGenerator(),
			enumGenerator: new TSExternEnumGenerator(),
			fileExtension: '.d.ts',
			stubs: false,
		},
		#end
	];
	
	#if macro
	public static function use() {
		if (!Context.defined('js')) return;
		
		#if (haxe_ver < 4)
		Context.onMacroContextReused(function() return false);
		#end
		
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
			
			
			for(config in generators) {
				// generate types
				for(type in types)  {
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
				if(config.mainGenerator != null)
					switch config.mainGenerator.generate(api, main, data) {
						case None:
						case Some(code): write(api.outputFile, code);
					}
			}
			
			// copy stubs
			if(generators.exists(function(config) return config.stubs))
				for(stub in stubs.keys()) {
					var name = stub + '_stub.js';
					if(FileSystem.exists(path + name))
					{
						try {
							var content = File.getContent(Context.resolvePath('stub/$name'));
							var existing = File.getContent(path + name);
							if (content == existing) continue;
						}
						catch (e:Dynamic) {}
					}
					File.copy(Context.resolvePath('stub/$name'), path + name);
				}
		});
	}
	static function write(path:String, content:String) {
		var dir = directory(path);
		if(!FileSystem.exists(dir)) FileSystem.createDirectory(dir);
		if(FileSystem.exists(path))
		{
			try {
				var existing = File.getContent(path);
				if (content == existing) return;
			}
			catch (e:Dynamic) {}
		}
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