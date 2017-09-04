package;

using sys.FileSystem;
using tink.CoreApi;

class RunTests {
	static function main() {
		for(path in 'tests'.readDirectory()) {
			var folder = 'tests/$path';
			if(folder.isDirectory()) {
				Sys.command('haxe', ['build.hxml','--cwd',folder]);
				Sys.command('node', ['$folder/bin/index.js']);
			}
		}
	}
}