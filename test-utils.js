(function() {
    var searchOriginal = function(obj) {
        if (obj._promise) {
            return obj;
        } else {
            return searchOriginal(obj.parent);
        }
    };

    sinon.stub.promise = function() {
        var obj = this;

        var returnedPromise = new Promise(function(_resolve_, _reject_){
            obj._resolvefn = _resolve_;
            obj._rejectfn = _reject_;
        });

        this.returns(returnedPromise);
        this._promise = true;

        return this;
    };

    sinon.stub.resolve = function() {
        var original = searchOriginal(this);
        original._resolvefn.apply(this, arguments);
    };

    sinon.stub.reject = function() {
        var original = searchOriginal(this);
        original._rejectfn.apply(this, arguments);
    };

    window.addDecorator = function() {};
}());
