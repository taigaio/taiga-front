/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');
var helper = module.exports;

helper.title = function() {
    let el = $('.e2e-story-header');

    let obj = {
        el: el,

        getTitle: function() {
            return el.$('.e2e-title-subject').getText();
        },

        setTitle: function(title) {
            browser
                .actions()
                .mouseMove(el.$('.e2e-detail-edit'))
                .click()
                .perform();

            el.$('.e2e-title-input').clear().sendKeys(title);
        },

        save: async function() {
            el.$('.e2e-title-button').click();
            await browser.waitForAngular();
        }
    };

    return obj;
};

helper.description = function(){
    let el = $('section[tg-editable-description]');

    let obj = {
        el: el,
        focus: function() {
            el.$('textarea').click();
        },
        enabledEditionMode: async function(){
            await el.$(".view-description").click();
        },

        getInnerHtml: async function(text){
            let html = await el.$(".wysiwyg.editable").getAttribute("innerHTML");
            return html;
        },

        setText: async function(text){
            await el.$("textarea").clear().sendKeys(text);
        },

        save: async function(){
            await el.$(".save").click();
            await browser.waitForAngular();
        }
    };

    return obj;
};


helper.tags = function() {
    let el = $('tg-tag-line-common');

    let obj = {
        el:el,

        clearTags: async function() {
            let tags = await el.$$('.e2e-delete-tag');
            let totalTags = tags.length;
            let htmlChanges = null;
            while (totalTags > 0) {
                htmlChanges = await utils.common.outerHtmlChanges(el.$(".tags-container"));
                await el.$$('.e2e-delete-tag').first().click();
                totalTags --;
                await htmlChanges();
            }
        },

        getTagsText: function() {
          return el.$$('tg-tag span').getText();
        },

        addTags: async function(tags) {
            let htmlChanges = null

            $('.e2e-show-tag-input').click();

            for (let tag of tags){
                htmlChanges = await utils.common.outerHtmlChanges(el.$(".tags-container"));
                el.$('.e2e-add-tag-input').sendKeys(tag);
                el.$('.save').click();
                await htmlChanges();
            }
        }
    };

    return obj;
};

helper.statusSelector = function() {
    let el = $('.ticket-data');

    let obj = {
        el: el,

        setStatus: async function(value) {
            let status = el.$('.detail-status-inner');

            await utils.popover.open(status, value);

            return this.getSelectedStatus();
        },
        getSelectedStatus: async function(){
            return el.$$('.detail-status-inner .e2e-status').first().getAttribute("innerHTML");
        }
    };

    return obj;
};

helper.assignedTo = function() {
    let el = $('.menu-secondary .assigned-to');

    let obj = {
        el: el,
        clear: async function() {
            if (await el.$('.icon-delete').isPresent()) {
                await browser.actions()
                    .mouseMove(el.$('.icon-delete'))
                    .click()
                    .perform();

                await utils.lightbox.confirm.ok();
                await browser.waitForAngular();
            }
        },
        assign: function() {
            el.$('.user-assigned').click();
        },
        getUserName: function() {
            return el.$('.user-assigned').getText();
        },
        isUnassigned: function() {
            return el.$('.assign-to-me').isPresent();
        }
    };

    return obj;
};

helper.history = function() {
    let el = $('section.history');
    let obj = {
        el:el,

        selectCommentsTab: async function() {
            el.$('.e2e-comments-tab').click();
            await browser.waitForAngular();
        },

        selectActivityTab: async function() {
            el.$('.e2e-activity-tab').click();
            await browser.waitForAngular();
        },

        countComments: async function() {
            let comments = await el.$$(".comment-wrapper");
            return comments.length;
        },

        countActivities: async function() {
            let activities = await el.$$(".activity");
            return activities.length;
        },

        countDeletedComments: async function() {
            let comments = await el.$$(".deleted-comment-wrapper");
            return comments.length;
        },

        editLastComment: async function() {
            let lastComment = el.$$(".comment-wrapper").last();
            browser
               .actions()
               .mouseMove(lastComment)
               .perform();

            lastComment.$$(".comment-option").first().click();
            await browser.waitForAngular();
        },

        deleteLastComment: async function() {
            let lastComment = el.$$(".comment-wrapper").last();

            browser
               .actions()
               .mouseMove(lastComment)
               .perform();

            lastComment.$$(".comment-option").last().click();
            await browser.waitForAngular();
        },

        getComments: function() {
            return $$('tg-comment');
        },

        showVersionsLastComment: async function() {
          el.$$(".comment-edited a").last().click();
          await browser.waitForAngular();
        },

        closeVersionsLastComment: async function() {
          $(".lightbox-display-historic .close").click();
          await browser.waitForAngular();
        },

        enableEditModeLastComment: async function() {
            let lastComment = el.$$(".comment-wrapper").last();
            browser
               .actions()
               .mouseMove(lastComment)
               .perform();

            lastComment.$$(".comment-option").last().click();
            await browser.waitForAngular();
        },

        restoreLastComment: async function() {
            el.$$(".deleted-comment-wrapper .restore-comment").last().click();
            await browser.waitForAngular();
        }
    };

    return obj;

};

helper.block = function() {
    let el = $('tg-block-button');

    let obj = {
        el:el,
        block: function() {
            el.$('.item-block').click();
        },
        unblock: async function() {
            el.$('.item-unblock').click();
        }
    };

    return obj;
};

helper.blockLightbox = function() {
    let el = $('div[tg-lb-block]');

    let obj = {
        el: el,
        waitOpen: function() {
            return utils.lightbox.open(el);
        },
        waitClose: function() {
            return utils.notifications.success.close();
        },
        fill: async function(text) {
            el.$('textarea').sendKeys(text);
            await browser.waitForAngular();
        },
        submit: async function() {
            el.$('a.button-green').click();
            await browser.waitForAngular();
        }
    };

    return obj;
};

helper.delete = function() {
    let el = $('tg-delete-button');

    let obj = {
        el:el,
        delete: async function(){
            el.$('.button-red').click();
            await utils.lightbox.confirm.ok();
        }
    };

    return obj;
};

helper.attachment = function() {
    let el = $('tg-attachments-full');

    let obj = {
        el:el,
        waitEditableClose: function() {
            return browser.wait(async () => {
                let editableAttachmentsCount = await $$('tg-attachment .editable-attachment-comment').count();

                return !editableAttachmentsCount;
            }, 5000);
        },
        upload: async function(filePath, name) {
            let addAttach = el.$('#add-attach');
            let countAttachments = await $$('tg-attachment').count();
            let toggleInput = function() {
                $('#add-attach').toggle();
            };

            await browser.executeScript(toggleInput);
            await el.$('#add-attach').sendKeys(filePath);
            await browser.waitForAngular();

            await browser.wait(async () => {
                let count = await $$('tg-attachment .editable-attachment-comment input').count();

                return !!count;
            }, 5000);

            await el.$('tg-attachment .editable-attachment-comment input').sendKeys(name);
            await browser.sleep(500);
            await browser.actions().sendKeys(protractor.Key.ENTER).perform();
            await browser.executeScript(toggleInput);
            await browser.waitForAngular();
            await obj.waitEditableClose();
        },

        renameLastAttchment: async function (name) {
            await browser.actions().mouseMove(el.$$('tg-attachment').last()).perform();

            let settingsGroup = el.$$('tg-attachment .attachment-settings').last();

            await settingsGroup.$$('.settings').first().click();

            await browser.wait(async () => {
                let count = await $$('tg-attachment .editable-attachment-comment input').count();

                return !!count;
            }, 5000);

            await el.$$('tg-attachment .editable-attachment-comment input').last().sendKeys(name);
            await browser.actions().sendKeys(protractor.Key.ENTER).perform();
            await browser.waitForAngular();
            await obj.waitEditableClose();
        },

        getFirstAttachmentName: async function () {
            let name = await el.$$('tg-attachment .attachment-comments').first().getText();
            return name;
        },

        getLastAttachmentName: async function () {
            let name = await el.$$('tg-attachment .attachment-comments').last().getText();
            return name;
        },

        countAttachments: async function(){
            return await el.$$('tg-attachment').count();
        },

        countDeprecatedAttachments: async function(){
            let hasDeprecateds = await el.$('.more-attachments .more-attachments-num').isPresent();

            if (hasDeprecateds) {
                let attachmentsJSON = await el.$('.more-attachments .more-attachments-num').getAttribute('translate-values');


                return parseInt(eval(attachmentsJSON));
            } else {
                return 0;
            }
        },

        deprecateLastAttachment: async function() {
            await browser.actions().mouseMove(el.$$('tg-attachment').last()).perform();

            let editEl = el.$$('tg-attachment').last().$('.attachment-settings .e2e-edit');
            await browser
                .actions()
                .mouseMove(editEl)
                .click()
                .perform();

            await el.$$('tg-attachment .editable-attachment-deprecated input').last().click();
            await el.$$('tg-attachment .attachment-settings').last().$('.e2e-save').click();
            await browser.waitForAngular();
        },

        showDeprecated: async function(){
            await el.$('.more-attachments-num').click();
        },

        deleteLastAttachment: async function() {
            let attachment = await $$('tg-attachment').last();

            await browser.actions().mouseMove(attachment).perform();

            let isEditable = await attachment.$('.editable').isPresent();

            // close edit
            if(isEditable) {
                let iconDelete = await attachment.$$('.attachment-settings a').get(1);
                await browser.actions().mouseMove(iconDelete).perform();

                iconDelete.click();

                await browser.waitForAngular();
            }

            let iconDelete = await attachment.$$('.attachment-settings a').get(1);
            await browser.actions().mouseMove(iconDelete).perform();

            iconDelete.click();

            await utils.lightbox.confirm.ok();
            await browser.waitForAngular();
        },

        dragLastAttchmentToFirstPosition: async function() {
            await browser.actions().mouseMove(el.$$('tg-attachment').last()).perform();
            let lastDraggableAttachment = el.$$('tg-attachment .attachment-settings a').last();
            let destination = el.$$('tg-attachment .attachment-settings').first();
            await utils.common.drag(lastDraggableAttachment, destination);
        },

        galleryImages: function() {
            return $$('tg-attachment-gallery');
        },

        gallery: function() {
            $('.view-gallery').click();
        },

        list: function() {
            $('.view-list').click();
        },
        previewLightbox: function() {
            return utils.lightbox.open($('tg-attachments-preview'));
        },
        getPreviewSrc: function() {
            return $('tg-attachments-preview img').getAttribute('src');
        },
        nextPreview: function() {
            return $('tg-attachments-preview .next').click();
        },
        attachmentLinks: function() {
            return $$('.e2e-attachment-link');
        }
    };

    return obj;
};



helper.watchers = function() {
    let el = $('.ticket-watch-buttons');

    let obj = {
        el: el,

        addWatcher: async function() {
            await el.$('.add-watcher').click();
        },

        getWatchersUserNames: async function() {
            return el.$$('.user-list-name span').getText();
        },

        removeAllWatchers: async function() {
            let totalWatchers = await await el.$$('.js-delete-watcher').count();

            if(!totalWatchers) return;

            let htmlChanges = htmlChanges = await utils.common.outerHtmlChanges(el);
            while (totalWatchers > 0) {
                await el.$$('.js-delete-watcher').first().click();
                await utils.lightbox.confirm.ok();
                totalWatchers --;
            }
            await htmlChanges();
        }
    };

    return obj;
};

helper.watchersLightbox = function() {
    let el = $('div[tg-lb-watchers]');

    let obj = {
        el: el,
        waitOpen: function() {
            return utils.lightbox.open(el);
        },
        waitClose: function() {
            return utils.lightbox.close(el);
        },
        close: function() {
            el.$$('.close').first().click();
        },
        selectFirst: async function() {
            el.$$('div[data-user-id]').first().click();
            await browser.waitForAngular();
        },
        getFirstName: function() {
            return el.$$('.lightbox .ticket-watchers div[data-user-id]').first().getText();
        },
        getNames: function() {
            return el.$$('.user-list-name').getText();
        },
        filter: function(text) {
            return el.$('input').sendKeys(text);
        },
        userList: function() {
            return el.$$('.user-list-single');
        }
    };

    return obj;
};

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
