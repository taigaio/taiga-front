var common = require('./common')

var lightbox = module.exports;
var transition = 300;

lightbox.open = function(el) {
    var deferred = protractor.promise.defer();

   browser
        .wait(function() {
            return common.hasClass($(el), 'open')
        }, 2000)
        .then(function(open) {
            return browser.sleep(transition).then(function() {
                if (open) {
                    deferred.fulfill(true);
                } else {
                    deferred.reject(new Error('Lightbox doesn\'t open'));
                }
            });
        });

    return deferred.promise;
};

lightbox.close = function(el) {
    var deferred = protractor.promise.defer();

    $(el).isPresent().then(function(present) {
        if (!present) {
            deferred.fulfill(true);
        } else {
            return browser.wait(function() {
                return common.hasClass($(el), 'open').then(function(open) {
                    return !open;
                });
            }, 2000)
                .then(function() {
                    return deferred.fulfill(true);
                }, function() {
                    deferred.reject(new Error('Lightbox doesn\'t close'));
                });
        }
    })

    return deferred.promise;
};
