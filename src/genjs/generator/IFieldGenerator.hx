package genjs.generator;

import haxe.ds.Option;
import haxe.macro.JSGenApi;
import genjs.processor.*;

using haxe.io.Path;
using StringTools;

interface IFieldGenerator {
	function generate(api:JSGenApi, f:ProcessedField, data:Dynamic):Option<String>;
}