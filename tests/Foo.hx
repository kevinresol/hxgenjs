package;

class Foo {
	public function new() {
		
	}
	
	public function foo() {
		trace('foo');
		trace(Bar.b);
		trace(new Bar());
		trace(Bar.bar());
	}
}