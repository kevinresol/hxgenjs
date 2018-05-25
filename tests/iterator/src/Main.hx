package;

import tink.unit.*;
import tink.unit.Assert.*;
import tink.testrunner.*;

using Lambda;

@:asserts
class Main {
	static function main() {
		Runner.run(TestBatch.make([
			new Main(),
		])).handle(Runner.exit);
	}
	
	function new() {}
	
	public function fold() {
		var arr = [1,2,3];
		var sum = arr.fold(function(i, sum) return sum + i, 0);
		return assert(sum == 6);
	}
}