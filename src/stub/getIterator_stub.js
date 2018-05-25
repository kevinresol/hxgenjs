Object.defineProperty(exports, "__esModule", { value: true });

var HxOverrides = require('./HxOverrides').default;

exports.default = function $getIterator(o) {
	if (o instanceof Array) 
		return HxOverrides.iter(o);
	else
		return o.iterator();
}