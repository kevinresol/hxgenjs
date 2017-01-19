package genjs.processor;

import haxe.Template;
import haxe.macro.Type;

typedef ProcessedField = {
	field:ClassField,
	code:String,
	template:Template,
	isStatic:Bool,
}