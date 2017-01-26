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
		trace(Validator.isEmail('kevin'));
		trace(Validator.isEmail('kevin@gamil.com'));
		trace(Redux.combineReducers);
		
		switch enm() {
			case A: trace('a');
			case B: trace('b');
		}
	}
	
	static function enm()
		return A;
}


@:jsRequire('validator')
extern class Validator {
	static var version:String;
	static function isEmail(v:String):Bool;
}

@:jsRequire('redux')
extern class Redux {
	static function createStore<S, A:{type:String}>(reducer:S->A->S, ?initialState:S, ?enhancer:Dynamic):Store<S, A>;
	static function combineReducers<S, A:{type:String}>(reducers:{}):S->A->S;
}

extern class Store<S, A:{type:String}> {
	function subscribe(listener:Void->Void):Void->Void;
	function getState():S;
	function dispatch(action:A):Void;
}

enum E {
	A;
	B;
}