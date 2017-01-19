package;

using tink.CoreApi;

class RunTests {
	static function main() {
		new Foo().foo();
		Bar.bar();
		trace(new Bar1());
		var trigger = Future.trigger();
		trigger.trigger('1');
		trigger.asFuture().handle(function(o) trace(o));
		var t = trigger.trigger;
		trace(t);
	}
}