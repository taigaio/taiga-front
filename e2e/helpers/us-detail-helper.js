/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');
var commonHelper = require('./common-helper');

var helper = module.exports;


helper.relatedTaskForm = async function(form, name, status, assigned_to) {
    await form.$('input').sendKeys(name);

    let taskStatus = form.$('.task-status');

    await utils.popover.open(taskStatus, status);

    form.$('.task-assignedto').click();

    let assignToLightbox = commonHelper.assignToLightbox();

    await assignToLightbox.waitOpen();
    await assignToLightbox.selectFirst();
    await assignToLightbox.waitClose();

    let saveBtn = form.$('.save-task');

    await browser.actions()
        .mouseMove(saveBtn)
        .click()
        .perform();
};

helper.createRelatedTasks = function(name, status, assigned_to) {
    $('section[tg-related-tasks] .add-button').click();

    let form = $('.related-task-create-form');

    return helper.relatedTaskForm(form, name, status, assigned_to);
};

helper.editRelatedTasks = async function(taskIndex, name, status, assigned_to) {
    let task = helper.relatedTasks().get(taskIndex);

    task.$('.edit-task').click();

    helper.relatedTaskForm(task, name, status, assigned_to);

    await browser.sleep(30000);
};

helper.editRelatedTasksEnabled = function() {
    return $$('related-task-create-form.active');
};

helper.deleteRelatedTask = function(taskIndex, name, status, assigned_to) {
    let task = helper.relatedTasks().get(taskIndex);

    browser
        .actions()
        .mouseMove(task.$('.delete-task'))
        .click()
        .perform();

    return utils.lightbox.confirm.ok();
};

helper.relatedTasks = function() {
    return $$('.js-related-task');
};
