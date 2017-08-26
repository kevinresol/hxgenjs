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
					for(i in 0...path.length) {
						current.push('["${path[i]}"]');
						var access = 'exports' + current.join('');
						
						if(i == path.length - 1)
							exposes.push('$access = ' + m.exposes[name].asAccessName());
						else
							exposes.push('$access = $access || {}');
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