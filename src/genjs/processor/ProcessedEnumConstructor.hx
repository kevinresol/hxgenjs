package genjs.processor;

import haxe.macro.Type;
import genjs.template.*;

typedef ProcessedEnumConstructor = {
	field:EnumField,
	template:EnumConstructorTemplate,
}