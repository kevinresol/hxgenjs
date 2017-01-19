package;

class Bar {
	public static var b = 1;
	public static var a = b + 1;
	
	public function new() {
		
	}
	
	public static function bar() {
		trace('bar' + a + b);
		return 1;
	}
}