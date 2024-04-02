/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');

var helper = module.exports;

helper.epic = function() {
    let el = $$('.e2e-epic');

    let obj = {
        el: el,
        getEpics: async function() {
            return el.count();
        },
        createEpic: async function(date, description) {
            $('.e2e-create-epic').click();
            utils.common.takeScreenshot("epics", "epics-create-epic");
            $('.e2e-create-epic-subject').clear().sendKeys(date + description);
            $('.e2e-create-epic-status').click();
            $$('.e2e-create-epic-status > option').get(0).click();
            $('.e2e-create-epic-description').clear().sendKeys(date + description);
            $('.e2e-create-epic-client-requirement').click();
            $('.e2e-create-epic-team-requirement').click();
            $('.e2e-create-epic-blocked').click();
            $('.e2e-create-epic-blocked-note').clear().sendKeys(date + description);
            $('.e2e-create-epic-button').click();
            await browser.waitForAngular();
        },
        displayUserStoriesinEpic: async function() {
            utils.common.takeScreenshot("epics", "epics-child-closed");
            let storiesCount = await el.count();
            let epicChildren;
            for (var i = 0; i < storiesCount; i++) {
                let story = await el.get(i);
                story.click();
                epicChildren = await story.$$('.e2e-story').count();
                if (epicChildren > 0) {
                    await utils.common.takeScreenshot("epics", "epics-child-open");
                    break;
                }
            }
            return epicChildren;
        },
        getAssignedTo: async function() {
            return await el.get(0).$('.e2e-assigned-to-image').getAttribute("title");
        },
        resetAssignedTo: async function() {
            el.get(0).$('.e2e-assigned-to-image').click();
            $$('.e2e-assigned-to-selector').get(0).click();
            await browser.waitForAngular();
        },
        editAssignedTo: async function() {
            el.get(0).$('.e2e-assigned-to-image').click();
            utils.common.takeScreenshot("epics", "epics-edit-assigned");
            $$('.e2e-assigned-to-selector').last().click();
            await browser.waitForAngular();
        },
        removeAssignedTo: async function() {
            el.get(0).$('.e2e-assigned-to-image').click();
            $('.e2e-unassign').click();
            await browser.waitForAngular();
            return el.get(0).$('.e2e-assigned-to-image').getAttribute("alt");
        },
        resetStatus: async function() {
            el.get(0).$('.e2e-epic-status').click();
            el.get(0).$$('.e2e-edit-epic-status').get(0).click();
            await browser.waitForAngular();
        },
        getStatus: function() {
            return el.get(0).$('.e2e-epic-status').getText();
        },
        editStatus: async function() {
            el.get(0).$('.e2e-epic-status').click();
            utils.common.takeScreenshot("epics", "epics-edit-status");
            el.get(0).$$('.e2e-edit-epic-status').last().click();
            await browser.waitForAngular();
        },
        getColumns: function() {
            return $$('.e2e-epics-table-header > div').count();
        },
        removeColumns: async function() {
            $('.e2e-epics-column-button').click();
            utils.common.takeScreenshot("epics", "epics-edit-columns");
            $$('.e2e-epics-column-dropdown .check').first().click();
            await browser.waitForAngular();
        }
    }

    return obj;
}

// helper.title = function() {
//     let el = $('.e2e-story-header');
//
//     let obj = {
//         el: el,
//
//         getTitle: function() {
//             return el.$('.e2e-title-subject').getText();
//         },
//
//         setTitle: function(title) {
//             el.$('.e2e-detail-edit').click();
//             el.$('.e2e-title-input').clear().sendKeys(title);
//         },
//
//         save: async function() {
//             el.$('.e2e-title-button').click();
//             await browser.waitForAngular();
//         }
//     };
//
//     return obj;
// };

//
// helper.getCreateIssueLightbox = function() {
//     let el = $('div[tg-lb-create-issue]');
//
//     let obj = {
//         el: el,
//         waitOpen: function() {
//             return utils.lightbox.open(el);
//         },
//         waitClose: function() {
//             return utils.lightbox.close(el);
//         },
//         subject: function() {
//             return el.$$('input').first();
//         },
//         tags: function() {
//             return el.$('.tag-input');
//         },
//         submit: function() {
//             el.$('button[type="submit"]').click();
//         }
//     };
//
//     return obj;
// };
//
// helper.getBulkCreateLightbox = function() {
//     let el = $('div[tg-lb-create-bulk-issues]');
//
//     let obj = {
//         el: el,
//         waitOpen: function() {
//             return utils.lightbox.open(el);
//         },
//         textarea: function() {
//             return el.$('textarea');
//         },
//         submit: function() {
//             el.$('button[type="submit"]').click();
//         },
//         waitClose: function() {
//             return utils.lightbox.close(el);
//         }
//     };
//
//     return obj;
// };
//
// helper.openNewIssueLb = function() {
//     $('.new-issue .button-green').click();
// };
//
// helper.openBulk = function() {
//     $('.new-issue .button-bulk').click();
// };
//
// helper.clickColumn = function(index) {
//     $$('.row.title > div').get(index).click();
// };
//
// helper.getTable = function() {
//     return $('.basic-table');
// };
//
// helper.openAssignTo = function(index) {
//     $$('.issue-assignedto').get(index).click();
// };
//
// helper.getAssignTo = function(index) {
//     return $$('.assigned-field figcaption').get(index).getText();
// };
//
// helper.clickPagination = function(index) {
//     $$('.paginator li').get(index).click();
// };
//
// helper.getIssues = function() {
//     return $$('.row.table-main');
// };
//
// helper.parseIssue = async function(elm) {
//     let obj = {};
//
//     obj.ref = await elm.$$('.subject span').get(0).getText();
//     obj.ref = obj.ref.replace('#', '');
//     obj.subject = await elm.$$('.subject span').get(1).getText();
//
//     return obj;
// };
