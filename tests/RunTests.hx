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
				Sys.println('');
				Sys.println(' ==== Running $folder ==== ');
				Sys.setCwd(folder);
				
				var version = Sys.getEnv('HAXE_VERSION');
				if(version == null || version == '') version = 'nightly';
				
				assertEquals(0, Sys.command('lix', ['download']));
				assertEquals(0, Sys.command('lix', ['use', 'haxe', version]));
				
				function sub(args:Array<String>) {
					Sys.println('haxe ' + args.join(' '));
					assertEquals(0, Sys.command('haxe', args));
					assertEquals(0, Sys.command('node', ['bin/index.js']));
				}
				
				sub(['build.hxml']);
				if(version != 'nightly') {
					// sub(['build.hxml', '-D', 'js_es=6']);
					sub(['build.hxml', '-D', 'hxextern']);
					sub(['build.hxml', '-D', 'tsextern']);
				}
				
				
				Sys.setCwd(cwd);
			}
		}
	}
}