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
	
	public function test() {
		asserts.assert(Type.getClassName(Type.getClass(this)) == 'Main');
		asserts.assert(Type.getClassName(Type.getClass(new foo.Foo())) == 'foo.Foo');
		return asserts.done();
	}
}