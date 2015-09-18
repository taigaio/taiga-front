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

helper.relatedTaskForm = function(form, name, status, assigned_to) {
   form.$('input').sendKeys(name);

    let taskStatus = form.$('.task-status');

    utils.popover.open(taskStatus, status);

    form.$('.assigned-to').click();

    let assignToLightbox = commonHelper.assignToLightbox();

    assignToLightbox.waitOpen();

    assignToLightbox.selectFirst();

    assignToLightbox.waitClose();

    form.$('.icon-floppy').click();
};

helper.createRelatedTasks = function(name, status, assigned_to) {
    $$('.related-tasks-buttons').get(0).click();

    let form = $('.related-task-create-form');

    helper.relatedTaskForm(form, status, assigned_to);
};

helper.editRelatedTasks = function(taskIndex, name, status, assigned_to) {
    let task = helper.relatedTasks().get(taskIndex);

    task.$('.icon-edit').click();

    helper.relatedTaskForm(task, status, assigned_to);
};

helper.deleteRelatedTask = function(taskIndex, name, status, assigned_to) {
    let task = helper.relatedTasks().get(taskIndex);

    task.$('.icon-delete').click();

    utils.lightbox.confirm.ok();
};

helper.relatedTasks = function() {
    return $$('.related-tasks-body .single-related-task');
};
