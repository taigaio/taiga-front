/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var common = require('./common');

var notifications = module.exports;

var transition = 600;

notifications.success = {};
notifications.success.open = function() {
    var el = $('.notification-message-success');

    return browser
        .wait(function() {
            return common.hasClass(el, 'active');
        }, 6000, "notification success open")
        .then(function(active) {
            return browser.sleep(transition).then(function() {
                return active;
            });
        });
};

notifications.success.close = function() {
    var el = $('.notification-message-success');

    return browser
        .wait(function() {
            return common.hasClass(el, 'inactive');
        }, 6000, "notification success close")
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
        }, 6000)
        .then(function(active) {
            return browser.sleep(transition).then(function() {
                return active;
            });
        });
};

notifications.error.close = function() {
    var el = $('.notification-message-error');

    return browser
        .wait(function() {
            return common.hasClass(el, 'inactive');
        }, 6000)
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
        }, 6000)
        .then(function(active) {
            return browser.sleep(transition).then(function() {
                return active;
            });
        });
};

notifications.errorLight.close = function() {
    var el = $('.notification-message-light-error');

    return browser
        .wait(function() {
            return common.hasClass(el, 'inactive');
        }, 6000)
        .then(function(active) {
            return browser.sleep(transition).then(function() {
                return active;
            });
        });
};
