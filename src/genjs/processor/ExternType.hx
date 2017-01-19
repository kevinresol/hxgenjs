package genjs.processor;

enum ExternType {
	None;
	Require(params:Array<String>);
	Native(name:String);
	Global;
}