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
            return el.$$('.ticket-role-points').last().$('.points').getText();
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
        waitClose: function() {
            return utils.lightbox.close(el);
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
    return $$('.backlog-table-body > div[ng-repeat]');
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

helper.openNewMilestone = function(item) {
    $('.add-sprint').click();
};

helper.toggleClosedSprints = function() {
    $('.filter-closed-sprints').click();
};

helper.closedSprints = function() {
    return $$('.sprint-closed');
};

helper.setUsStatus = async function(item, value) {
    let status = $$('.backlog-table-body > div .us-status').get(item);

    await utils.popover.open(status, value);

    return status.$$('span').first().getText();
};

helper.setUsPoints = async function(item, value1, value2)  {
    let points = $$('.backlog-table-body > div .us-points').get(item).$$('span').get(0);

    return  utils.popover.open(points, value1, value2);
};

helper.getUsPoints = async function(item)  {
    return $$('.backlog-table-body > div .us-points').get(item).$$('span').get(0).getText();
};

helper.deleteUs = function(item) {
    $$('.backlog-table-body > div .icon-delete').get(item).click();
};

helper.getUsRef = function(elm) {
    return elm.$('span[tg-bo-ref]').getText();
};

// get ref with the larger length
helper.getTestingFilterRef = async function() {
    let userstories = helper.userStories();
    let userstoriesCount = await userstories.count();
    let ref = '';

    for(let i = 0; i < userstoriesCount; i++) {
        let userstory = userstories.get(i);
        let newRef = await helper.getUsRef(userstory);

        if (newRef.length > ref.length) {
            ref = newRef;
        }
    }

    return ref;
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

helper.goBackFilters = function() {
    return $$('.filters-step-cat .breadcrumb a').first().click();
};

helper.fiterRole = async function(value) {
    let rolePointsSelector = $('div[tg-us-role-points-selector]');

    return utils.popover.open(rolePointsSelector, value);
};
