var common = require('./common')

var lightbox = module.exports;
var transition = 300;

lightbox.open = async function(el) {
    var deferred = protractor.promise.defer();

    if (typeof el == 'string' || el instanceof String) {
        el = $(el);
    }

    let open = await browser.wait(function() {
        return common.hasClass(el, 'open')
    }, 4000);

    await browser.sleep(transition);

    if (open) {
        deferred.fulfill(true);
    } else {
        deferred.reject(new Error('Lightbox doesn\'t open'));
    }

    return deferred.promise;
};

lightbox.close = async function(el) {
    var deferred = protractor.promise.defer();
    var present = true;

    if (typeof el == 'string' || el instanceof String) {
        el = $(el);
    }

    present = await el.isPresent();

    if (!present) {
        deferred.fulfill(true);
    } else {
        return browser.wait(function() {
            return common.hasClass(el, 'open').then(function(open) {
                return !open;
            });
        }, 4000)
            .then(function() {
                return deferred.fulfill(true);
            }, function() {
                deferred.reject(new Error('Lightbox doesn\'t close'));
            });
    }

    return deferred.promise;
};

lightbox.confirm = {};

lightbox.confirm.ok = async function() {
    let lb = $('.lightbox-generic-ask');
    await lightbox.open(lb);

    lb.$('.button-green').click();

    await lightbox.close(lb);
};
