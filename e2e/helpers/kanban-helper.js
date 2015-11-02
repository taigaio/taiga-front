var utils = require('../utils');

var helper = module.exports;

helper.getHeaderColumns = function() {
    return $$('.task-colum-name');
};

helper.openNewUsLb = function(column) {
    helper.getHeaderColumns().get(column).$('.icon-plus').click();
};

helper.getColumns = function() {
    return $$('.task-column');
};

helper.getColumnUssTitles = function(column) {
    return helper.getColumns().$$('.task-name').getText();
};

helper.getBoxUss = function(column) {
    return helper.getColumns().get(column).$$('.kanban-task');
};

helper.editUs = function(column, us) {
    helper.getColumns().get(column).$$('.icon-edit').get(us).click();
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

helper.foldCards = function(column) {
    let columnNode = helper.getHeaderColumns().get(column);

    columnNode.$$('.options a').get(2).click();
};

helper.unFoldCards = function(column) {
    let columnNode = helper.getHeaderColumns().get(column);

    columnNode.$$('.options a').get(3).click();
};

helper.scrollRight = function() {
    return browser.executeScript('$(".kanban-table-body:last").scrollLeft(10000);');
};

helper.watchersLinks = function() {
    return $$('.task-assigned');
};
