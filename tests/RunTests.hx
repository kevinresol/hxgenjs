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
		var cwd = Sys.getCwd();
		for(path in 'tests'.readDirectory()) {
			var folder = 'tests/$path';
			if(folder.isDirectory()) {
				trace('Running $folder');
				Sys.setCwd(folder);
				assertEquals(0, Sys.command('lix', ['download']));
				assertEquals(0, Sys.command('haxe', ['build.hxml']));
				assertEquals(0, Sys.command('node', ['bin/index.js']));
				Sys.setCwd(cwd);
			}
		}
	}
}