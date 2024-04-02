/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
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
