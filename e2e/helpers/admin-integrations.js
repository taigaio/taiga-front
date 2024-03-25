/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');

var helper = module.exports;

helper.saveWebHook = async function(name, email, key) {
    let inputs = $$('input[type="text"]');

    await inputs.get(0).clear();
    await inputs.get(1).clear();
    await inputs.get(2).clear();

    await inputs.get(0).sendKeys(name);
    await inputs.get(1).sendKeys(email);
    await inputs.get(2).sendKeys(key);

    // debounce
    await browser.sleep(2000);

    let newWebHook = await $('.add-new').isDisplayed();

    if(newWebHook) {
        await $('.add-new').click();
        return browser.waitForAngular();
    } else {
        await $('.edit-existing').click();
        return browser.waitForAngular();
    }
};

helper.getErrors = function() {
    return $$('.checksley-error-list');
};

helper.currentWebHookIsPresent = function() {
    return $('div[tg-webhook]').isPresent();
};

helper.deleteWebhook = async function() {
    let deleteButton = $('.delete-webhook');

    await browser.actions().mouseMove(deleteButton).click().perform();

    await utils.lightbox.confirm.ok();

    return browser.waitForAngular();
};

helper.openEditModeWebHook = function() {
    let editButton = $('.edit-webhook');

    editButton.click();
};

helper.getWebHookMode = async function() {
    let visualizationMode = $('.visualization-mode');

    let vModeState = await utils.common.hasClass(visualizationMode, 'hidden');

    if (vModeState) return 'edit';
    else return 'read';
};
