var utils = require('../utils');

var helper = module.exports;

helper.getCreateEditUsLightbox = function() {
    let el = $('div[tg-lb-create-edit-userstory]');

    let obj = {
        el: el,
        waitOpen: function() {
            return utils.lightbox.open(el);
        },
        waitClose: function() {
            return utils.lightbox.close(el);
        },
        roles: function() {
            return el.$$('.points-per-role li');
        },
        subject: function() {
            return el.$('input[name="subject"]');
        },
        tags: function() {
            return el.$('.tag-input');
        },
        description: function() {
            return el.$('textarea[name="description"]');
        },
        status: function(item) {
            return el.$(`select option:nth-child(${item})`);
        },
        settings: function(item) {
            return el.$$('.settings label').get(item).click();
        },
        submit: function() {
            el.$('button[type="submit"]').click();
        },
        setRole: function(roleItem, value) {
            let role = obj.roles().get(roleItem);

            return utils.popover.open(role, value);
        },
        getRolePoints: function() {
            let role = obj.roles().get(0);

            return role.$('.points').getText();
        }
    };

    return obj;
};

helper.getBulkCreateLightbox = function() {
    let el = $('div[tg-lb-create-bulk-userstories]');

    let obj = {
        el: el,
        waitOpen: function() {
            return utils.lightbox.open(el);
        },
        textarea: function() {
            return el.$('textarea');
        },
        submit: function() {
            el.$('button[type="submit"]').click();
        },
        waitClose: function() {
            return utils.lightbox.close(el);
        }
    };

    return obj;
};

helper.getCreateEditMilestone = function() {
    let el = $('div[tg-lb-create-edit-sprint]');

    let obj = {
        el: el,
        waitOpen: function() {
            return utils.lightbox.open(el);
        },
        name: function() {
            return el.element(by.model('sprint.name'));
        },
        submit: function() {
            el.$('button[type="submit"]').click();
        },
        delete: function() {
            el.$('.delete-sprint .icon-delete').click();
        }
    };

    return obj;
};

helper.userStories = function() {
    return $$('.backlog-table-body > div');
};

helper.selectedUserStories = function() {
    return $$('.backlog-table-body input[type="checkbox"]:checked');
};

helper.sprints = function() {
    return $$('div[tg-backlog-sprint="sprint"]');
};

helper.sprintsOpen = function() {
    return $$('div[tg-backlog-sprint="sprint"].sprint-open');
};

helper.openBulk = function() {
    $$('.new-us a').get(1).click();
};

helper.openNewUs = function() {
    $$('.new-us a').get(0).click();
};

helper.openUsBacklogEdit = function(item) {
    $$('.backlog-table-body .icon-edit').get(item).click();
};

helper.openMilestoneEdit = function(item) {
    $$('div[tg-backlog-sprint="sprint"] .icon-edit').get(item).click();
};

helper.setUsStatus = async function(item, value) {
    let status = $$('.backlog-table-body > div .us-status').get(item);

    await utils.popover.open(status, value);

    return status.$$('span').first().getText();
};

helper.setUsPoints = function(item, value1, value2)  {
    let points = $$('.backlog-table-body > div .us-points').get(item);

    return  utils.popover.open(points, value1, value2);
};

helper.deleteUs = function(item) {
    $$('.backlog-table-body > div .icon-delete').get(item).click();
};

helper.getUsRef = function(elm) {
    return elm.$('span[tg-bo-ref]').getText();
};

helper.getSprintUsertories = function(sprint) {
    return sprint.$$('.milestone-us-item-row');
};

helper.getSprintsRefs = function(sprint) {
    return sprint.$$('span[tg-bo-ref]').getText();
};

helper.getSprintsTitles = function() {
    return $$('div[tg-backlog-sprint="sprint"] .sprint-name span').getText();
};
