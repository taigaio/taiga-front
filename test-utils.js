/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

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
