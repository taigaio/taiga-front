var common = require('./common')

var lightbox = module.exports;
var transition = 300;

lightbox.open = function(el) {
    var deferred = protractor.promise.defer();

    if (typeof el == 'string' || el instanceof String) {
        el = $(el);
    }

   browser
        .wait(function() {
            return common.hasClass(el, 'open')
        }, 2000)
        .then(function(open) {
            return browser.sleep(transition).then(function() {
                if (open) {
                    deferred.fulfill(open);
                } else {
                    deferred.reject(new Error('Lightbox doesn\'t open'));
                }
            });
        });

    return deferred.promise;
};

lightbox.close = function(el) {
    if (typeof el == 'string' || el instanceof String) {
        el = $(el);
    }

   return browser.wait(function() {
        return common.hasClass(el, 'open').then(function(open) {
            return !open;
        });
    }, 2000);
};
