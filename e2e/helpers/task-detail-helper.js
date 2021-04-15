/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (c) 2021-present Kaleidos Ventures SL
 */

var utils = require('../utils');

var helper = module.exports;

helper.iocaine = function() {
    let el = $('tg-task-is-iocaine-button fieldset');

    let obj = {
        el: el,

        togleIocaineStatus: async function(){
            await el.$("label").click();
            await browser.waitForAngular();
        },

        isIocaine: async function() {
            let classes = await el.$("label").getAttribute('class');
            return classes.includes("active");
        }
    };

    return obj;
};
