package genjs.generator;

import haxe.ds.Option;
import haxe.macro.JSGenApi;
import genjs.processor.*;

class MainGenerator {
	public static function generate(api:JSGenApi, m:ProcessedMain, data:Dynamic) {
		
		var requireStatements = RequireGenerator.generate(api, '', m.dependencies);
		
		return switch m.template {
			case null: None;
			case template: Some(requireStatements + '\n' + template.execute(data) + ';');
		}
	}
}