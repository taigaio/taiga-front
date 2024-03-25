/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

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
        tags: async function() {
            $('.e2e-show-tag-input').click();
            $('.e2e-open-color-selector').click();

            $$('.e2e-color-dropdown li').get(1).click();
            $('.e2e-add-tag-input')
                .sendKeys('xxxyy')
                .sendKeys(protractor.Key.ENTER);

            $$('.e2e-delete-tag').last().click();

            $('.e2e-add-tag-input')
                .sendKeys('a')
                .sendKeys(protractor.Key.ARROW_DOWN)
                .sendKeys(protractor.Key.ENTER);
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
            el.$('.delete-sprint').click();
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

helper.velocityForecasting = function() {
    return $$('.e2e-velocity-forecasting');
};

helper.openVelocityForecasting = function() {
    $$('.e2e-velocity-forecasting').click();
};

helper.createSprintFromForecasting = function() {
    $$('.e2e-velocity-forecasting-add').click();
    let sprintName = 'sprintName' + new Date().getTime();
    $('.e2e-sprint-name')
        .sendKeys(sprintName)
        .sendKeys(protractor.Key.ENTER);
};

helper.openUsBacklogEdit = function(item) {
    $$('.backlog-table-body .e2e-edit').get(item).click();
};

helper.openMilestoneEdit = function(item) {
    $$('div[tg-backlog-sprint="sprint"] .edit-sprint').get(item).click();
};

helper.openNewMilestone = function(item) {
    $('.add-sprint').click();
};

helper.getClosedSprintTable = function() {
    return $$('.sprint-empty').last();
};

helper.toggleClosedSprints = function() {
    $('.filter-closed-sprints').click();
};

helper.toggleSprint = async function(el) {
    el.$('.compact-sprint').click();

    await utils.common.waitTransitionTime(el.$('.sprint-table'));
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
    $$('.backlog-table-body > div .e2e-delete').get(item).click();
};

helper.getUsRef = function(elm) {
    return elm.$('span[tg-bo-ref]').getText();
};

helper.loadFullBacklog = async function() {
    do {
        var uss = helper.userStories();
        var count = await uss.count();
        var last = uss.last();

        await browser.executeScript("arguments[0].scrollIntoView();", last.getWebElement());

        var newcount = await uss.count();
    } while(count < newcount);
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
