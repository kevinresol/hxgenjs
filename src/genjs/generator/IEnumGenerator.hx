package genjs.generator;

import haxe.ds.Option;
import haxe.macro.JSGenApi;
import genjs.processor.*;

using tink.MacroApi;
using haxe.io.Path;
using StringTools;
using genjs.template.CodeTools;

interface IEnumGenerator {
	function generate(api:JSGenApi, e:ProcessedEnum):Option<String>;
}