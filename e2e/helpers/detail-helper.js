var utils = require('../utils');
var helper = module.exports;

helper.title = function() {
    let el = $('span[tg-editable-subject]');

    let obj = {
        el: el,

        getTitle: function() {
          return el.$('.view-subject').getText();
        },

        setTitle: function(title) {
          el.$('.view-subject').click();
          el.$('.edit-subject input').clear().sendKeys(title);
        }
    };

    return obj;
};

helper.description = function(){
    let el = $('section[tg-editable-description]');

    let obj = {
        el: el,

        enabledEditionMode: async function(){
            await el.$(".view-description").click();
        },

        getInnerHtml: async function(text){
            let html = await el.$(".wysiwyg.editable").getInnerHtml();
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
    let el = $('div[tg-tag-line]');

    let obj = {
        el:el,

        clearTags: async function() {
            let tags = await el.$$('.icon-delete');
            let totalTags = tags.length;
            while (totalTags > 0) {
              el.$$('.icon-delete').first().click();
              await browser.waitForAngular();
              totalTags --;
            }
        },

        getTagsText: async function() {
          let tags = await el.$$('.tag-name');
          let text = "";
          for (let tag of tags) {
              let tagText = await tag.getText();
              text += tagText;
          }
          return text;
        },

        addTags: async function(tags) {
            el.$('.add-tag').click();
            for (let tag of tags){
                el.$('.tag-input').sendKeys(tag);
                browser.actions().sendKeys(protractor.Key.ENTER).perform();
            }
        }
    };

    return obj;
};

helper.statusSelector = function() {
    let el = $('.us-status');

    let obj = {
        el: el,

        setStatus: async function(value) {
            let status = el.$('.status-data');
            await utils.popover.open(status, value);
            return this.getSelectedStatus()
        },
        getSelectedStatus: async function(){
            return el.$('.status-status').getInnerHtml();
        },
        getGeneralStatus: async function(){
            return el.$('.us-detail-status').getInnerHtml();
        },
    };

    return obj;
};

helper.assignedTo = function() {
    let el = $('.menu-secondary .assigned-to');

    let obj = {
        el: el,

        clear: async function() {
            await browser.actions().mouseMove(el).perform();

            el.$('.icon-delete').click();
            await utils.lightbox.confirm.ok();
            await browser.waitForAngular();
        },

        assign: function() {
          el.$('.user-assigned').click();
        },

        getUserName: function() {
          return el.$('.user-assigned').getText();
        }

    };

    return obj;
};

helper.assignToLightbox = function() {
    let el = $('div[tg-lb-assignedto]');

    let obj = {
        el: el,
        waitOpen: function() {
            return utils.lightbox.open(el);
        },
        waitClose: function() {
            return utils.lightbox.close(el);
        },
        selectFirst: function() {
            el.$$('div[data-user-id]').first().click();
        }

    };

    return obj;
};

helper.history = function() {
    let el = $('section.history');
    let obj = {
        el:el,

        selectCommentsTab: function() {
            el.$$('.history-tabs li a').first().click();
        },

        selectActivityTab: function() {
            el.$$('.history-tabs li a').last().click();
        },

        addComment: async function(comment) {
            el.$('textarea[tg-markitup]').sendKeys(comment);
            el.$('input.save-comment').click();
            await browser.waitForAngular();
        },

        countComments: async function() {
            let moreComments = el.$('.comments-list .show-more-comments');
            let moreCommentsIsPresent = await moreComments.isPresent();
            if (moreCommentsIsPresent){
                moreComments.click();
            }
            await browser.waitForAngular();
            let comments = await el.$$(".activity-single.comment");
            return comments.length;
        },

        countActivities: async function() {
            let moreActivities = el.$('.changes-list .show-more-comments');
            let selectActivityTabIsPresent = await moreActivities.isPresent();
            if (selectActivityTabIsPresent){
                utils.common.link(moreActivities);
                // moreActivities.click();
            }
            await browser.waitForAngular();
            let activities = await el.$$(".activity-single.activity");
            return activities.length;
        },

        countDeletedComments: async function() {
            let moreComments = el.$('.comments-list .show-more-comments');
            let moreCommentsIsPresent = await moreComments.isPresent();
            if (moreCommentsIsPresent){
                moreComments.click();
            }
            await browser.waitForAngular();
            let comments = await el.$$(".activity-single.comment.deleted-comment");
            return comments.length;
        },

        deleteLastComment: async function() {
            el.$$(".activity-single.comment .comment-delete").last().click();
            await browser.waitForAngular();
        },

        restoreLastComment: async function() {
            el.$$(".activity-single.comment.deleted-comment .comment-restore").last().click();
            await browser.waitForAngular();
        }
    }

    return obj;

}

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
        fill: function(text) {
            el.$('textarea').sendKeys(text);
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
    let el = $('tg-attachments');

    let obj = {
        el:el,
        upload: async function(filePath, name) {
            let addAttach = el.$('#add-attach');

            let toggleInput = function() {
                $('#add-attach').toggle();
            };

            await browser.executeScript(toggleInput);
            await el.$('#add-attach').sendKeys(filePath);
            await browser.waitForAngular();
            //TODO: ask JF why this is needed
            await browser.sleep(2000);
            await el.$$('div[tg-attachment] .editable-attachment-comment input').last().sendKeys(name);
            await browser.actions().sendKeys(protractor.Key.ENTER).perform();
            await browser.executeScript(toggleInput);
            await browser.waitForAngular();
        },

        renameLastAttchment: async function (name) {
            await browser.actions().mouseMove(el.$$('div[tg-attachment]').last()).perform();
            await el.$$('div[tg-attachment] .attachment-settings .icon-edit').last().click();
            await el.$$('div[tg-attachment] .editable-attachment-comment input').last().sendKeys(name);
            await browser.actions().sendKeys(protractor.Key.ENTER).perform();
            await browser.waitForAngular();
        },

        getFirstAttachmentName: async function () {
            let name = await el.$$('div[tg-attachment] .attachment-comments').first().getText();
            return name;
        },

        getLastAttachmentName: async function () {
            let name = await el.$$('div[tg-attachment] .attachment-comments').last().getText();
            return name;
        },

        countAttachments: async function(){
            return await el.$$('div[tg-attachment]').count();
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
            await browser.actions().mouseMove(el.$$('div[tg-attachment]').last()).perform();
            await el.$$('div[tg-attachment] .attachment-settings .icon-edit').last().click();
            await el.$$('div[tg-attachment] .editable-attachment-deprecated input').last().click();
            await el.$$('div[tg-attachment] .attachment-settings .editable-settings.icon-floppy').last().click();
            await browser.waitForAngular();
        },

        showDeprecated: async function(){
            await el.$('.more-attachments-num').click();
        },

        deleteLastAttachment: async function() {
            let attachment = await $$('div[tg-attachment]').last();

            await browser.actions().mouseMove(attachment).perform();

            let isEditable = await attachment.$('.editable').isPresent();

            // close edit
            if(isEditable) {
                let iconDelete = await attachment.$('.attachment-settings .icon-delete');
                await browser.actions().mouseMove(iconDelete).perform();

                iconDelete.click();

                await browser.waitForAngular();
            }

            let iconDelete = await attachment.$('.attachment-settings .icon-delete');
            await browser.actions().mouseMove(iconDelete).perform();

            iconDelete.click();

            await utils.lightbox.confirm.ok();
            await browser.waitForAngular();
        },

        dragLastAttchmentToFirstPosition: async function() {
            await browser.actions().mouseMove(el.$$('div[tg-attachment]').last()).perform();
            let lastDraggableAttachment = el.$$('div[tg-attachment] .attachment-settings .icon-drag-v').last();
            let destination = el.$$('div[tg-attachment] .attachment-settings .icon-drag-v').first();
            await utils.common.drag(lastDraggableAttachment, destination);
        }
    };

    return obj;
};



helper.watchers = function() {
    let el = $('section[tg-watchers]');

    let obj = {
        el: el,

        addWatcher: function() {
            el.$('.add-watcher').click();
        },

        getWatchersUserNames: function() {
            return el.$$('.watcher-name span').getText();
        },

        removeAllWathchers: async function() {
            let deleteIcons = await el.$$('.icon-delete')
            let totalWatchers = deleteIcons.length;

            while (totalWatchers > 0) {
              el.$$('.icon-delete').first().click()
              await utils.lightbox.confirm.ok();
              await browser.waitForAngular();
              totalWatchers --;
            }
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
        selectFirst: async function() {
            el.$$('div[data-user-id]').first().click();
            await browser.waitForAngular();
        },
        getFirstName: function() {
            return el.$$('div[data-user-id] .watcher-name').first().getText();
        }

    };

    return obj;
};
