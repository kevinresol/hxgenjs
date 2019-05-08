package;

import tink.unit.*;
import tink.unit.Assert.*;
import tink.testrunner.*;

@:asserts
class Main extends Base {
	static function main() {
		Runner.run(TestBatch.make([
			new Main(),
		])).handle(Runner.exit);
	}
	
	function new() {}
	
	public function getClassName() {
		asserts.assert(Type.getClass(this) == Main);
		asserts.assert(Type.getClassName(Type.getClass(this)) == 'Main');
		asserts.assert(Type.getClassName(Main) == 'Main');
		
		var f = new foo.Foo();
		asserts.assert(Type.getClass(f) == foo.Foo);
		asserts.assert(Type.getClassName(Type.getClass(f)) == 'foo.Foo');
		asserts.assert(Type.getClassName(foo.Foo) == 'foo.Foo');
		return asserts.done();
	}
	
	public function getSuperClass() {
		var superClass = Type.getSuperClass(Main);
		asserts.assert(superClass == Base);
		asserts.assert(Type.getClassName(superClass) == 'Base');
		return asserts.done();
	}
	
	public function resolveClass() {
		asserts.assert(Type.resolveClass('Main') == Main);
		asserts.assert(Type.resolveClass('foo.Foo') == foo.Foo);
		return asserts.done();
	}
	
	public function getEnumName() {
		asserts.assert(Type.getEnumName(Bar) == 'Bar');
		asserts.assert(Type.getEnumName(Type.getEnum(A)) == 'Bar');
		return asserts.done();
	}
	
	public function resolveEnum() {
		asserts.assert(Type.resolveEnum('Bar') == Bar);
		return asserts.done();
	}
	
	public function isClass() {
		asserts.assert(Std.is(Main, Class));
		asserts.assert(Std.is(foo.Foo, Class));
		return asserts.done();
	}
	
	public function isEnum() {
		asserts.assert(Std.is(Bar, Enum));
		return asserts.done();
	}
	
	public function isClassInstance() {
		asserts.assert(Std.is(this, Main));
		asserts.assert(Std.is(new foo.Foo(), foo.Foo));
		return asserts.done();
	}
	
	public function isEnumValue() {
		asserts.assert(Std.is(A, Bar));
		return asserts.done();
	}
}

enum Bar {
	A;
	B;
	C(c:Int);
}

class Base {}