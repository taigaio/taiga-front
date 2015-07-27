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

    us.$('.icon-plus').click();
};

helper.openBulkTaskLb = function(row) {
    let us = helper.usertories().get(row);

    us.$('.icon-bulk').click();
};

helper.foldRow = function(row) {
    let icon = $$('.icon-vfold.vfold').get(row);

    icon.click();

    return utils.common.waitRequestAnimationFrame();
};

helper.unFoldRow = function(row) {
    let icon = $$('.icon-vunfold.vunfold').get(row);

    icon.click();

    return utils.common.waitRequestAnimationFrame();
};

helper.foldColumn = function(row) {
    let icon = $$('.icon-vfold.hfold').get(row);

    icon.click();

    return utils.common.waitRequestAnimationFrame();
};

helper.unFoldColumn = function(row) {
    let icon = $$('.icon-vunfold.hunfold').get(row);

    icon.click();

    return utils.common.waitRequestAnimationFrame();
};

helper.editTask = function(row, column, task) {
    helper.getBoxTasks(row, column).get(task).$('.icon-edit').click();
};

helper.toggleGraph = function() {
    $('.large-summary svg').click();
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
            return el.$('textarea[name="blocked_note"]');
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
