package;

import tink.unit.*;
import tink.unit.Assert.*;
import tink.testrunner.*;

@:asserts
class Main {
	static function main() {
		Runner.run(TestBatch.make([
			new Main(),
		])).handle(Runner.exit);
	}
	
	function new() {}
	
	public function getClassName() {
		asserts.assert(Type.getClassName(Type.getClass(this)) == 'Main');
		asserts.assert(Type.getClassName(Main) == 'Main');
		asserts.assert(Type.getClassName(Type.getClass(new foo.Foo())) == 'foo.Foo');
		asserts.assert(Type.getClassName(foo.Foo) == 'foo.Foo');
		asserts.assert(Type.getEnumName(Bar) == 'Bar');
		asserts.assert(Type.getEnumName(Type.getEnum(A)) == 'Bar');
		return asserts.done();
	}
	
	public function resolveClass() {
		asserts.assert(Type.resolveClass('Main') == Main);
		asserts.assert(Type.resolveClass('foo.Foo') == foo.Foo);
		asserts.assert(Type.resolveEnum('Bar') == Bar);
		return asserts.done();
	}
}

enum Bar {
	A;
	B;
	C(c:Int);
}