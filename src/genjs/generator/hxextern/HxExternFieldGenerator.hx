package genjs.generator;

import haxe.ds.Option;
import haxe.macro.JSGenApi;
import genjs.processor.*;

using haxe.io.Path;
using StringTools;

class FieldGenerator {
	public static function generate(api:JSGenApi, f:ProcessedField, data:Dynamic) {
		if(f.template == null) return None;
		return Some(switch f.isStatic {
			case true: Reflect.field(data, 'className') + '.${f.field.name} = ' + f.template.execute(data);
			case false: f.field.name + ': ' + f.template.execute(data);
		});
	}
}