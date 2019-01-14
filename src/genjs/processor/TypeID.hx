package genjs.processor;

using StringTools;

@:forward
abstract TypeID(String) from String to String {
	
	public inline function asFilePath() return this.replace('.', '/');
	
	public inline function asTemplateHolder() return this.replace('_', '__').replace('.', '_');
	
	public inline function asVarSafeName() return this.replace('_', '_$$').replace('.', '_');
	
	public inline function asAccessName(?externType:ExternType)
		return switch externType {
			case Native(_):
				this;
			case null | None | Require([_], true):
				'(' + asVarSafeName() + '()' + '.default' + ')';
			case Require([_], false):
				'(' + asVarSafeName() + '()' + ')';
			case Require(fields, isDefault) if(fields.length > 1):
				'(' + asVarSafeName() + '()' + (isDefault ? '.default' : '') + '.' + fields.slice(1).join('.') + ')';
			default:
				asVarSafeName();
		}
}