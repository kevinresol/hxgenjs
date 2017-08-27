package genjs.processor;

import haxe.macro.Type;

typedef ProcessedEnum = {
	id:TypeID,
	type:EnumType,
	ref:Type,
	constructors:Array<ProcessedEnumConstructor>,
	dependencies:Array<Dependency>,
}