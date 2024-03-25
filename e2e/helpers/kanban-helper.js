/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');

var helper = module.exports;

helper.getHeaderColumns = function() {
    return $$('.task-colum-name');
};

helper.openNewUsLb = function(column) {
    helper.getHeaderColumns().get(column).$$('.option').get(2).click();
};

helper.getColumns = function() {
    return $$('.task-column');
};

helper.getColumnUssTitles = function(column) {
    return helper.getColumns().$$('.e2e-title').getText();
};

helper.getBoxUss = function(column) {
    return helper.getColumns().get(column).$$('tg-card');
};

helper.getUss = function() {
    return $$('tg-card');
};

helper.editUs = async function(column, us) {
    let editionZone = helper.getColumns().get(column).$$('.card-owner-actions').get(us);

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

helper.openBulkUsLb = function(column) {
    $$('.icon-bulk').get(column).click();
};

helper.foldColumn = function(column) {
    let columnNode = helper.getHeaderColumns().get(column);

    columnNode.$$('.options a').get(0).click();
};

helper.unFoldColumn = function(column) {
    let columnNode = helper.getHeaderColumns().get(column);

    columnNode.$$('.options a').get(1).click();
};

helper.scrollRight = function() {
    return browser.executeScript('$(".kanban-table-body:last").scrollLeft(10000);');
};

helper.watchersLinks = function() {
    return $$('.e2e-assign');
};

helper.zoom = async function(level) {
    return  browser
        .actions()
        .mouseMove($('tg-board-zoom'), {y: 14, x: level * 49})
        .click()
        .perform();
};
