package genjs.processor;

import haxe.ds.Option;
import haxe.Template;
import haxe.macro.Type;

typedef ProcessedField = {
	field:ClassField,
	code:String,
	template:Template,
	isStatic:Bool,
	isFunction:Bool,
	expose:Option<String>,
}