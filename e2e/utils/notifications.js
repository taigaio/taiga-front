var common = require('./common');

var notifications = module.exports;

var transition = 600;

notifications.success = {};
notifications.success.open = function() {
    var el = $('.notification-message-success');

    return browser
        .wait(function() {
            return common.hasClass(el, 'active');
        }, 2000)
        .then(function(active) {
            return browser.sleep(transition).then(function() {
                return active;
            });
        });
};

notifications.error = {};
notifications.error.open = function() {
    var el = $('.notification-message-error');

    return browser
        .wait(function() {
            return common.hasClass(el, 'active');
        }, 2000)
        .then(function(active) {
            return browser.sleep(transition).then(function() {
                return active;
            });
        });
};

notifications.errorLight = {};
notifications.errorLight.open = function() {
    var el = $('.notification-message-light-error');

    return browser
        .wait(function() {
            return common.hasClass(el, 'active');
        }, 2000)
        .then(function(active) {
            return browser.sleep(transition).then(function() {
                return active;
            });
        });
};
