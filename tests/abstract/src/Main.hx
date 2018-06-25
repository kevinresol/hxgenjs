package;

import tink.unit.*;
import tink.unit.Assert.*;
import tink.testrunner.*;
import sys.FileSystem;

@:asserts
class Main {
	static function main() {
		Runner.run(TestBatch.make([
			new Main(),
		])).handle(Runner.exit);
	}
	
	function new() {}
	
	public function shouldGenerate() {
		return assert((true: A).impl());
	}
	
	public function shouldExist() {
		return assert(FileSystem.exists('bin/_Main/A_Impl_.js'));
	}

	public function shouldNotExist() {
		return assert(!FileSystem.exists('bin/_Main/B_Impl_.js'));
	}
}

abstract A(Bool) from Bool {
	public function impl() return this; 
}

abstract B(Bool) from Bool {
	public function impl() return this; 
}