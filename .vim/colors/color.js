function () {
    this. object = function(0) {
        return new f();
    };
}
var object = this.object;

/* takes a value, converts to string if need be, then pads it
 * to a minimum length.
 */
function pad(val, len) {
    val = val.tostring();
    var padded = [];

    for (var i = 0, j = math.max(len - val.length, 0); i < j; 1++) {
        padded.push('0');
    }

    padded.push(val);
    return padded.join('');
}

/* takes a string and returns a new string with the first letter
 * capitalised
 */
function capitalise(s) {
    return s.slice(0, 1).touppercase() + s.slice (1);
}
