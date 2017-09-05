package;

import haxe.unit.*;
using sys.FileSystem;

class RunTests extends TestCase {
	static function main() {
		var r = new TestRunner();
		r.add(new RunTests());
		Sys.exit(r.run() ? 0 : 500);
	}
	
	function tests() {
		for(path in 'tests'.readDirectory()) {
			var folder = 'tests/$path';
			if(folder.isDirectory()) {
				trace('Running $folder');
				assertEquals(0, Sys.command('lix', ['download']));
				assertEquals(0, Sys.command('haxe', ['build.hxml','--cwd',folder]));
				assertEquals(0, Sys.command('node', ['$folder/bin/index.js']));
			}
		}
	}
}