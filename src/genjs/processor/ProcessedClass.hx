package genjs.processor;

import haxe.macro.Type;

typedef ProcessedClass = {
	id:TypeID,
	type:ClassType,
	fields:Array<ProcessedField>,
	constructor:ProcessedField,
	dependencies:Array<Dependency>,
}
