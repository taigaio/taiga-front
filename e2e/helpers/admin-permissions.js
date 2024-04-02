/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');

var helper = module.exports;

helper.newRole = async function(roleName) {
    $('div[tg-new-role] .add-button').click();

    await $('div[tg-new-role] input').sendKeys(roleName);


    await browser.actions().sendKeys(protractor.Key.ENTER).perform();
};

helper.getRoles = function() {
    return $$('.admin-submenu-roles li');
};

helper.editRole = async function(roleName) {
    let elm = $('tg-edit-role');
    let editButton = elm.$('.edit-value');

    await browser.actions()
        .mouseMove(editButton)
        .click()
        .perform();

    await elm.$('.edit-role input').sendKeys(roleName);
    await elm.$('.save').click();
};

helper.toggleEstimationRole = function() {
    $('.general-category input').click();
};

helper.openCategory = function(index) {
    let category = $$('.category-config').get(index);

    category.$('.resume').click();

    let cateogoryItems = category.$('.category-items');

    return utils.common.waitTransitionTime(cateogoryItems);
};

helper.getPermissionsCategory = function(index) {
    let category = $$('.category-config').get(index);

    return category.$$('.category-item');
};

helper.toggleCategoryPermission = function(elm) {
    elm.$('input').click();
};

helper.getCategoryPermissionValue = async function(elm) {
    let ok = await elm.$('input').getAttribute('checked');

    return (ok === 'true');
};

helper.delete = function() {
    $('.action-buttons .delete-role').click();
};
