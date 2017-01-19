package genjs.processor;

using StringTools;

abstract TypeID(String) from String to String {
	public inline function asFilePath() return this.replace('.', '/');
	public inline function asTemplateHolder() return this.replace('_', '__').replace('.', '_');
	public inline function asVarSafeName() return this.replace('_', '_$$').replace('.', '_');
}