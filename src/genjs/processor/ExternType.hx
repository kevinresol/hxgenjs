package genjs.processor;

enum ExternType {
	None;
	Require(params:Array<String>, isDefault:Bool);
	Native(name:String);
	Global;
	CoreApi;
}