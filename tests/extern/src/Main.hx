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
	
	static function __init__() {
		untyped __js__('global.foo = {Foo: function() {this.foo = "foo";}}');
	}
	
	function new() {}
	
	public function global() {
		asserts.assert(new foo.Foo().foo == 'foo');
		return asserts.done();
	}
}
