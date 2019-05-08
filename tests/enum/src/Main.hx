package;

import tink.unit.*;
import tink.unit.Assert.*;
import tink.testrunner.*;
import foo.Foo;

@:asserts
class Main {
	static function main() {
		Runner.run(TestBatch.make([
			new Main(),
		])).handle(Runner.exit);
	}
	
	function new() {}
	
	public function root() {
		asserts.assert(getRoot(false).match(A));
		asserts.assert(getRoot(true).match(B(1, 'a')));
		return asserts.done();
	}
	
	public function pack() {
		asserts.assert(getPack(false).match(C));
		asserts.assert(getPack(true).match(D(1, 'b')));
		return asserts.done();
	}
	
	function getRoot(arg):MyEnum return arg ? B(1, 'a') : A;
	function getPack(arg):Foo return arg ? D(1, 'b') : C;
}

enum MyEnum {
	A;
	B(i:Int, s:String);
}