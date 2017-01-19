Object.defineProperty(exports, "__esModule", {value: true});

var HxOverrides = require('./HxOverrides');
var $bind = require('./bind_stub');

exports.default = function $iterator(o) {
    if( o instanceof Array ) {
        return function() {
            return HxOverrides.default.iter(o);
        };
    }
    return typeof(o.iterator) == 'function' ? $bind.default(o,o.iterator) : o.iterator;
}