/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var common = require('./common');

var lightbox = module.exports;
var transition = 300;

lightbox.exit = function(el) {
    if (!el) {
        el = $('.lightbox.open');
    }

    if (typeof el === 'string' || el instanceof String) {
        el = $(el);
    }

    el.$('.close').click();

    return lightbox.close(el);
};

lightbox.open = async function(el) {
    var deferred = protractor.promise.defer();

    if (typeof el === 'string' || el instanceof String) {
        el = $(el);
    }

    let open = await browser.wait(function() {
        return common.hasClass(el, 'open');
    }, 4000);

    await browser.sleep(transition + 100);

    if (open) {
        deferred.fulfill(true);
    } else {
        deferred.reject(new Error('Lightbox doesn\'t open'));
    }

    return deferred.promise;
};

lightbox.close = async function(el) {
    var present = true;

    if (typeof el == 'string' || el instanceof String) {
        el = $(el);
    }

    present = await el.isPresent();

    if (present) {
        try {
            await browser.wait(async function() {
                let open = await common.hasClass(el, 'open');
                return !open;
            }, 4000);
        } catch (e) {
            new Error('Lightbox doesn\'t close')
            return false;
        }
    }

    return true;
};

lightbox.confirm = {};

lightbox.confirm.ok = async function() {
    let lb = $('.lightbox-generic-ask');
    await lightbox.open(lb);

    lb.$('.button-green').click();

    await lightbox.close(lb);
};


lightbox.confirm.cancel = async function() {
    let lb = $('.lightbox-generic-ask');
    await lightbox.open(lb);

    lb.$('.button-red').click();

    await lightbox.close(lb);
};
