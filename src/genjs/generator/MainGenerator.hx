package genjs.generator;

import haxe.ds.Option;
import haxe.macro.JSGenApi;
import genjs.processor.*;

class MainGenerator {
	public static function generate(api:JSGenApi, m:ProcessedMain, data:Dynamic) {
		
		
		return switch m.template {
			case null: None;
			case template:
				var requireStatements = RequireGenerator.generate(api, '', m.dependencies);
				var main = template.execute(data) + ';';
				var exposes = [];
				for(name in m.exposes.keys()) {
					var path = name.split('.');
					
					var current = [];
					var access = switch m.exposes[name] {
						case EClass(cls): cls.id.asAccessName();
						case EClassField(cls, field): cls.id.asAccessName() + '.' + field.field.name;
					}
					
					for(i in 0...path.length) {
						current.push('["${path[i]}"]');
						var export = 'exports' + current.join('');
						
						if(i == path.length - 1)
							exposes.push('$export = $access');
						else
							exposes.push('$export = $export || {}');
					}
				}
				
				Some([
					requireStatements,
					main,
					exposes.join('\n'),
				].join('\n'));
		}
	}
}