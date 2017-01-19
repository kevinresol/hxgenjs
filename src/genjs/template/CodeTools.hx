package genjs.template;

class CodeTools  {
	public static function indent(s:String, depth:Int)
		return s.split('\n').map(function(line) return StringTools.lpad('', '\t', depth) + line).join('\n');
}