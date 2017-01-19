package genjs.processor;

import haxe.macro.Type;

typedef ProcessedEnum = {
	id:TypeID,
	type:EnumType,
	constructors:Array<ProcessedEnumConstructor>,
	dependencies:Array<Dependency>,
}