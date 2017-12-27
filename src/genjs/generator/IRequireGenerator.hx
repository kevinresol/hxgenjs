package genjs.generator;

import haxe.macro.JSGenApi;
import genjs.processor.*;

interface IRequireGenerator {
	function generate(api:JSGenApi, currentPath:String, dependencies:Array<Dependency>):String;
}