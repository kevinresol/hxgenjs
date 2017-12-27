package genjs.generator;

import haxe.ds.Option;
import haxe.macro.JSGenApi;
import genjs.processor.*;

using tink.MacroApi;

using Lambda;

interface IMainGenerator {
	function generate(api:JSGenApi, m:ProcessedMain, data:Dynamic):Option<String>;
}