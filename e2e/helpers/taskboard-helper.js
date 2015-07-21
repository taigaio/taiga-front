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
        submit: function() {
            el.$('button[type="submit"]').click();
        }
    };

    return obj;
};
