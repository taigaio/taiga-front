var utils = require('../utils');
var commonHelper = require('./common-helper');

var helper = module.exports;

helper.teamRequirement = function() {
    let el = $('tg-us-team-requirement-button');

    let obj = {
        el: el,

        toggleStatus: async function(){
            await el.$("label").click();
            await browser.waitForAngular();
        },

        isRequired: async function() {
            let classes = await el.$("label").getAttribute('class');
            return classes.includes("active");
        }
    };

    return obj;
};

helper.clientRequirement = function() {
    let el = $('tg-us-client-requirement-button');

    let obj = {
        el: el,

        toggleStatus: async function(){
            await el.$("label").click();
            await browser.waitForAngular();
        },

        isRequired: async function() {
            let classes = await el.$("label").getAttribute('class');
            return classes.includes("active");
        }
    };

    return obj;
};

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

    return helper.relatedTaskForm(form, status, assigned_to);
};

helper.editRelatedTasks = function(taskIndex, name, status, assigned_to) {
    let task = helper.relatedTasks().get(taskIndex);

    task.$('.edit-task').click();

    return helper.relatedTaskForm(task, status, assigned_to);
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
