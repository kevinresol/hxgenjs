package genjs.processor;

import haxe.macro.Type;

enum Dependency {
	DType(type:Type);
	DStub(name:String);
}