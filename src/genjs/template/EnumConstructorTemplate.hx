package genjs.template;

import haxe.Template;

abstract EnumConstructorTemplate(Template) {
	public inline function new(s:String)
		this = new Template(s);
	
	public function execute(enumName:String)
		return this.execute({enumName: enumName});
}