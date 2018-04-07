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
	
	public function subclass() {
		return assert(new Child().foo);
	}
}

class Base {}
class Child extends Base {
	public var foo:Bool = true;
	public function new() {}
}