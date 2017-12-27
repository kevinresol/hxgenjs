package genjs.generator;

import haxe.ds.Option;
import haxe.macro.JSGenApi;
import genjs.processor.*;

interface IClassGenerator {
	function generate(api:JSGenApi, c:ProcessedClass):Option<String>;
}