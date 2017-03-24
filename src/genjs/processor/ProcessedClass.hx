package genjs.processor;

import haxe.macro.Type;

typedef ProcessedClass = {
	id:TypeID,
	type:ClassType,
	fields:Array<ProcessedField>,
	constructor:ProcessedField,
	init:{code:String, template:haxe.Template},
	dependencies:Array<Dependency>,
	externType:ExternType,
}
