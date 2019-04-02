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
		untyped __js__('global.foo = {0}', {
			Foo: function() js.Lib.nativeThis.foo = 'foo',
			Bar: {Baz: 'baz'},
		});
		untyped __js__('global.native = {0}', {
			Foo: function() js.Lib.nativeThis.foo = 'native_foo',
			Bar: {Baz: 'native_baz'},
		});
	}
	
	function new() {}
	
	public function globalClass() {
		asserts.assert(new foo.Foo().foo == 'foo');
		return asserts.done();
	}
	
	public function globalEnum() {
		asserts.assert(foo.Bar.Baz == cast 'baz');
		return asserts.done();
	}
	
	public function nativeClass() {
		asserts.assert(new foo.NativeFoo().foo == 'native_foo');
		return asserts.done();
	}
	
	public function nativeEnum() {
		asserts.assert(foo.NativeBar.Baz == cast 'native_baz');
		return asserts.done();
	}
}
