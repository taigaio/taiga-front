/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');

var helper = module.exports;

helper.getCreateIssueLightbox = function() {
    let el = $('div[tg-lb-create-issue]');

    let obj = {
        el: el,
        waitOpen: function() {
            return utils.lightbox.open(el);
        },
        waitClose: function() {
            return utils.lightbox.close(el);
        },
        subject: function() {
            return el.$$('input').first();
        },
        tags: function() {
            return el.$('.tag-input');
        },
        submit: function() {
            el.$('button[type="submit"]').click();
        }
    };

    return obj;
};

helper.getBulkCreateLightbox = function() {
    let el = $('div[tg-lb-create-bulk-issues]');

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

helper.openNewIssueLb = function() {
    $('.new-issue .button-green').click();
};

helper.openBulk = function() {
    $('.new-issue .button-bulk').click();
};

helper.clickColumn = function(index) {
    $$('.row.title > div').get(index).click();
};

helper.getTable = function() {
    return $('.basic-table');
};

helper.openAssignTo = function(index) {
    $$('.issue-assignedto').get(index).click();
};

helper.changeStatus = function(index, statusIndex) {
    let status = $$('.issue-status').get(index);

    return utils.popover.open(status, statusIndex);
};

helper.getStatus = function() {
    return $$('.issue-status').getText();
};

helper.getAssignTo = function(index) {
    return $$('.assigned-field figcaption').get(index).getText();
};

helper.clickPagination = function(index) {
    $$('.paginator li').get(index).click();
};

helper.getIssues = function() {
    return $$('.row.table-main');
};

helper.parseIssue = async function(elm) {
    let obj = {};

    obj.ref = await elm.$$('.subject span').get(0).getText();
    obj.ref = obj.ref.replace('#', '');
    obj.subject = await elm.$$('.subject span').get(1).getText();

    return obj;
};
