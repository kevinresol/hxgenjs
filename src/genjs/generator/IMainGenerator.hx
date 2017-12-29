package genjs.generator;

import haxe.ds.Option;
import haxe.macro.JSGenApi;
import genjs.processor.*;

#if tink_macro
using tink.MacroApi;
#end

using Lambda;

interface IMainGenerator {
	function generate(api:JSGenApi, m:ProcessedMain, data:Dynamic):Option<String>;
}