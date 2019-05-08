package genjs.processor;

import haxe.ds.Option;
import haxe.Template;
import haxe.macro.Type;
import haxe.macro.JSGenApi;
import genjs.processor.Dependency;
import genjs.processor.ExternType;

using StringTools;
#if tink_macro
using tink.MacroApi;
#else
using genjs._util.MacroUtil;
using haxe.macro.ExprTools;
#end

class ClassProcessor {
	static var cache = new Map();
	
	public static function process(api:JSGenApi, id:String, cls:ClassType, ?ref:Type):ProcessedClass {
		if(!cache.exists(id)) {
			
			var ids = [id];
			var stubs = ['hxClasses' #if haxe4, 'hxEnums' #end];
			var dependencies = [];
			
			// add interfaces and superclass to dependency list
			switch cls.interfaces {
				case null | []: // do nothing;
				case v:
					for(i in v) {
						ids.push(i.t.toString());
						dependencies.push(DType(TInst(i.t, [])));
					}
			}
			switch cls.superClass {
				case null: // do nothing;
				case {t: type}:
					ids.push(type.toString());
					dependencies.push(DType(TInst(type, [])));
			}
			
			function checkStubDependency(name:String, code:String) {
				if(stubs.indexOf(name) != -1) return;
				if(code.indexOf('$$$name') != -1) stubs.push(name);
			}
			
			api.setCurrentClass(cls);
			api.setTypeAccessor(function(type) {
				if(stubs.indexOf('import') == -1) stubs.push('import');
				var id:TypeID = type.getID();
						
						// FIXME:
						// JQuery appears as a ClassType with {module: "js.jquery.JQuery", name: "$", pack: []}
						// see: https://github.com/HaxeFoundation/haxe/issues/7639
						if(id == "$") return "$"; 
				
				if(ids.indexOf(id) == -1) {
					ids.push(id);
					dependencies.push(DType(type));
				}
				return '::' + id.asTemplateHolder() + '::';
			});
			
			function constructField(f:ClassField, isStatic:Bool) {
				var code = switch f.expr() {
					case null: null;
					case e: 
						var code = api.generateValue(e);
						checkStubDependency('iterator', code);
						checkStubDependency('getIterator', code);
						checkStubDependency('bind', code);
						checkStubDependency('extend', code);
						code;
				}
				
				var meta = f.meta.extract(':expose');
				var expose =
					if(!isStatic || meta.length == 0) Option.None
					else if(meta[0].params.length == 0) Some('$id.${f.name}');
					else Some(meta[0].params[0].getValue());
				
				return {
					field: f,
					isStatic: isStatic,
					isFunction: f.kind.match(FMethod(_)),
					expose: expose,
					code: code,
					template: code == null ? null : new Template(code),
				}
			}
			
			var fields = cls.fields.get().map(constructField.bind(_, false));
			var statics = cls.statics.get().map(constructField.bind(_, true));
			var constructor = switch cls.constructor {
				case null if(cls.isInterface):
					var code = 'function() {}';
					{
						field: null,
						isStatic: false,
						isFunction: true,
						expose: Option.None,
						code: code,
						template: new Template(code),
					}
				case null: null;
				case ctor: constructField(ctor.get(), false);
			}
			var init = switch cls.init {
				case null: null;
				case expr:
					var code = api.generateStatement(expr);
					
					#if haxe4
					// HACK: make sure top-level types are registered in hxClasses
					if(id == 'Std') {
						code = code.replace('var Int', 'var Int = $$hxClasses["Int"]');
						code = code.replace('var Dynamic', 'var Dynamic = $$hxClasses["Dynamic"]');
						code = code.replace('var Float', 'var Float = $$hxClasses["Float"]');
						code = code.replace('var Bool', 'var Bool = $$hxClasses["Bool"]');
						code = code.replace('var Class', 'var Class = $$hxClasses["Class"]');
						code = code.replace('var Enum', 'var Enum = $$hxClasses["Enum"]');
					}
					#end
					checkStubDependency('iterator', code);
					checkStubDependency('getIterator', code);
					checkStubDependency('bind', code);
					checkStubDependency('extend', code);
					{
						code: code,
						template: code == null ? null : new Template(code),
					}
			}
			
			if(cls.superClass != null) stubs.push('extend');
			
			
			inline function m(name) return cls.meta.extract(name);
			var externType =
				if(!cls.isExtern) None
				else switch [m(':jsRequire'), m(':native'), m(':coreApi')] {
					case [[v], _, _]: 
						var params:Array<String> = v.params.map(function(e) return e.getValue());
						var isDefault = false;
						if(params[1] != null && params[1].startsWith('default')) {
							isDefault = true;
							params[1] = params[1].substr('default'.length);
							if(params[1].startsWith('.')) params[1] = params[1].substr(1);
							if(params[1] == '') params.splice(1, 1);
						}
						Require(params, isDefault);
					case [_, [v], _]: Native(v.params[0].getValue());
					case [_, _, [v]]: CoreApi;
					default: Global;
				}
			
			var meta = m(':expose');
			var expose =
				if(meta.length == 0) Option.None
				else if(meta[0].params.length == 0) Some(id)
				else Some(meta[0].params[0].getValue());
			
			
			if(ref == null) throw 'Type reference cannot be null when a class is processed for the first time';
			cache[id] = {
				id: id,
				type: cls,
				ref: ref,
				fields: fields.concat(statics),
				init: init,
				constructor: constructor,
				dependencies: stubs.map(DStub).concat(dependencies),
				externType: externType,
				expose: expose,
			}
		}
		return cache[id];
	}
}