package genjs.processor;

import haxe.ds.Option;
import haxe.macro.Type;

typedef ProcessedClass = {
	id:TypeID,
	type:ClassType,
	ref:Type,
	fields:Array<ProcessedField>,
	constructor:ProcessedField,
	init:{code:String, template:haxe.Template},
	dependencies:Array<Dependency>,
	externType:ExternType,
	expose:Option<String>,
}
