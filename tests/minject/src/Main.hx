package;

import tink.unit.*;
import tink.unit.Assert.*;
import tink.testrunner.*;
import haxe.rtti.Meta;

@:asserts
class Main {
	static function main() {
		Runner.run(TestBatch.make([
			new Main(),
		])).handle(Runner.exit);
	}
	
	function new() {}
	
	public function inject() {
		var injector  = new minject.Injector();
		var v = 10;
		injector.map(Int).toValue(v);
		var foo = injector.instantiate(Foo);
		asserts.assert(foo.i == v);
		return asserts.done();
	}
}

class Foo {
	public var i(default, null):Int;
	
	public function new() {}
	
	@inject public function injection(i:Int) {
		this.i = i;
	}
}