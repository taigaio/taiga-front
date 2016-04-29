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

    return box.$$('.taskboard-task');
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

helper.editTask = function(row, column, task) {
    helper.getBoxTasks(row, column).get(task).$('.edit-task').click();
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
    return $$('.task-assigned');
};
