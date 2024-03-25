/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');

var helper = module.exports;

helper.usertories = function() {
    return $$('.task-row');
};

helper.getBox = function(row, column) {
    return $$('.task-row').get(row).$$('.taskboard-tasks-box').get(column);
};

helper.getBoxTasks = function(row, column) {
    let box = helper.getBox(row, column);

    return box.$$('tg-card');
};

helper.getTasks = function() {
    return $$('tg-card');
};

helper.openNewTaskLb = function(row) {
    let us = helper.usertories().get(row);

    us.$('.add-action').click();
};

helper.openBulkTaskLb = function(row) {
    let us = helper.usertories().get(row);

    us.$('.bulk-action').click();
};

helper.foldRow = function(row) {
    let icon = $$('.vfold.fold-action').get(row);

    icon.click();
};

helper.unFoldRow = function(row) {
    let icon = $$('.vunfold.fold-action').get(row);

    icon.click();
};

helper.foldColumn = function(row) {
    let icon = $$('.hfold.fold-action').get(row);

    icon.click();
};

helper.unFoldColumn = function(row) {
    let icon = $$('.hunfold.fold-action').get(row);

    icon.click();
};

helper.editTask = async function(row, column, task) {
    let editionZone = helper.getBoxTasks(row, column).$$('.card-owner-actions').get(task);

    await browser
        .actions()
        .mouseMove(editionZone)
        .perform();

    return browser
        .actions()
        .mouseMove(editionZone)
        .mouseMove(editionZone.$('.e2e-edit'))
        .click()
        .perform();
};

helper.toggleGraph = function() {
    $('.toggle-analytics-visibility').click();
};

helper.getCreateTask = function() {
    let el = $('div[tg-lb-create-edit-task]');

    let obj = {
        el: el,
        waitOpen: function() {
            return utils.lightbox.open(el);
        },
        subject: function() {
            return el.element(by.model('task.subject'));
        },
        description: function() {
            return el.element(by.model('task.description'));
        },
        tags: function() {
            return el.$('.tag-input');
        },
        iocaine: function() {
            return el.$('.iocaine');
        },
        blocked: function() {
            return el.$('.blocked');
        },
        blockedNote: function() {
            return el.$('input[name="blocked_note"]');
        },
        submit: function() {
            el.$('button[type="submit"]').click();
        }
    };

    return obj;
};

helper.getBulkCreateTask = function() {
    let el = $('div[tg-lb-create-bulk-tasks]');

    let obj = {
        el: el,
        waitOpen: function() {
            return utils.lightbox.open(el);
        },
        textarea: function() {
            return el.element(by.model('form.data'));
        },
        submit: function() {
            el.$('button[type="submit"]').click();
        }
    };

    return obj;
};

helper.watchersLinks = function() {
    return $$('.e2e-assign');
};

helper.zoom = async function(level) {
    return  browser
        .actions()
        .mouseMove($('tg-board-zoom'), {y: 14, x: level * 66})
        .click()
        .perform();
};
