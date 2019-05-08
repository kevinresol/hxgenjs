package;

import tink.unit.*;
import tink.testrunner.*;
using sys.FileSystem;

@:asserts
@:timeout(999999)
class RunTests {
	static function main() {
		Runner.run(TestBatch.make([
			new RunTests(),
		])).handle(Runner.exit);
	}
	
	function new() {}
	
	public function tests() {
		var cwd = Sys.getCwd();
		for(path in 'tests'.readDirectory()) {
			var folder = 'tests/$path';
			if(folder.isDirectory()) {
				Sys.println('');
				Sys.println(' ==== Running $folder ==== ');
				Sys.setCwd(folder);
				
				var version = Sys.getEnv('HAXE_VERSION');
				if(version == null || version == '') version = 'nightly';
				
				asserts.assert(Sys.command('lix', ['download']) == 0);
				asserts.assert(Sys.command('lix', ['use', 'haxe', version]) == 0);
				
				function sub(args:Array<String>) {
					Sys.println('haxe ' + args.join(' '));
					asserts.assert(Sys.command('haxe', args) == 0);
					asserts.assert(Sys.command('node', ['bin/index.js']) == 0);
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
		return asserts.done();
	}
}