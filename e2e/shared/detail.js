var path = require('path');
var detailHelper = require('../helpers').detail;
var commonHelper = require('../helpers').common;
var customFieldsHelper = require('../helpers/custom-fields-helper');
var commonUtil = require('../utils/common');
var notifications = require('../utils/notifications');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

var shared = module.exports;

shared.titleTesting = async function() {
    let titleHelper = detailHelper.title();
    let title = await titleHelper.getTitle();
    let date = Date.now();

    titleHelper.setTitle("New title " + date);
    titleHelper.save();

    let newTitle = await titleHelper.getTitle();
    expect(notifications.success.open()).to.be.eventually.true;
    expect(newTitle).to.be.not.equal(title);

    await notifications.success.close();
}

shared.tagsTesting = async function() {
    let tagsHelper = detailHelper.tags();
    let tagsText = await tagsHelper.getTagsText();
    await tagsHelper.clearTags();
    let date = Date.now();
    let tags = [1, 2, 3].map((i) => date + "-" + i);

    await tagsHelper.addTags(tags);

    let newtagsText = await tagsHelper.getTagsText();

    expect(newtagsText).to.be.not.eql(tagsText);
}

shared.descriptionTesting = async function() {
    let descriptionHelper = detailHelper.description();
    let description = await descriptionHelper.getInnerHtml();
    let date = Date.now();
    descriptionHelper.enabledEditionMode();
    descriptionHelper.setText("New description " + date);
    descriptionHelper.save();

    let newDescription = await descriptionHelper.getInnerHtml();

    expect(notifications.success.open()).to.be.eventually.true;
    expect(newDescription).to.be.not.equal(description);

    await notifications.success.close();
}

shared.statusTesting = async function(status1 , status2) {
    let statusHelper = detailHelper.statusSelector();

    // Status 1
    await statusHelper.setStatus(1);

    let selectedStatus = await statusHelper.getSelectedStatus();

    expect(selectedStatus).to.be.equal(status1);

    // Status 2
    await statusHelper.setStatus(2);

    let newSelectedStatus = await statusHelper.getSelectedStatus();
    expect(newSelectedStatus).to.be.equal(status2);
}

shared.assignedToTesting = function() {
    before(function () {
        let assignedTo = detailHelper.assignedTo();

        return assignedTo.clear();
    });

    it('assign', async function() {
        let assignedTo = detailHelper.assignedTo();
        let assignToLightbox = commonHelper.assignToLightbox();
        let userName = detailHelper.assignedTo().getUserName();

        assignedTo.assign();

        await assignToLightbox.waitOpen();

        assignToLightbox.selectFirst();

        await assignToLightbox.waitClose();

        let newUserName = assignedTo.getUserName();

        expect(newUserName).to.be.not.equal(userName);
    });

    it('unassign', async function() {
        let assignedTo = detailHelper.assignedTo();

        await assignedTo.clear();

        expect(assignedTo.isUnassigned()).to.be.eventually.true;
    });

    it('filter', async function () {
        let assignedTo = detailHelper.assignedTo();
        let assignToLightbox = commonHelper.assignToLightbox();

        assignedTo.assign();

        await assignToLightbox.waitOpen();

        let names = await assignToLightbox.getNames();

        await assignToLightbox.filter(names[0]);

        let newNames = await assignToLightbox.getNames();

        expect(newNames).to.have.length(1);

        assignToLightbox.selectFirst();

        await assignToLightbox.waitClose();
        await notifications.success.close();
    });

    it('keyboard navigatin', async function() {
        let assignedTo = detailHelper.assignedTo();
        let assignToLightbox = commonHelper.assignToLightbox();

        assignedTo.assign();

        await assignToLightbox.waitOpen();

        browser
           .actions()
           .sendKeys(protractor.Key.ARROW_DOWN)
           .sendKeys(protractor.Key.ARROW_DOWN)
           .sendKeys(protractor.Key.ARROW_DOWN)
           .sendKeys(protractor.Key.ARROW_UP)
           .perform();

        let selected = assignToLightbox.userList().get(2);

        let isSelected = await commonUtil.hasClass(selected, 'selected');

        expect(isSelected).to.be.true;

        assignToLightbox.close();

        await assignToLightbox.waitClose();
    });
}

shared.historyTesting = async function() {
    let historyHelper = detailHelper.history();

    //Adding a comment
    historyHelper.selectCommentsTab();
    let commentsCounter = await historyHelper.countComments();
    let date = Date.now();
    await historyHelper.addComment("New comment " + date);
    let newCommentsCounter = await historyHelper.countComments();
    expect(newCommentsCounter).to.be.equal(commentsCounter+1);


    //Deleting last comment
    let deletedCommentsCounter = await historyHelper.countDeletedComments();
    await historyHelper.deleteLastComment();
    let newDeletedCommentsCounter = await historyHelper.countDeletedComments();
    expect(newDeletedCommentsCounter).to.be.equal(deletedCommentsCounter+1);

    //Restore last coment
    deletedCommentsCounter = await historyHelper.countDeletedComments();
    await historyHelper.restoreLastComment();
    newDeletedCommentsCounter = await historyHelper.countDeletedComments();
    expect(newDeletedCommentsCounter).to.be.equal(deletedCommentsCounter-1);

    //Check activity
    historyHelper.selectActivityTab();

    let activitiesCounter = await historyHelper.countActivities();

    expect(activitiesCounter).to.be.least(newCommentsCounter);
}

shared.blockTesting = async function() {
    let blockHelper = detailHelper.block();
    let blockLightboxHelper = detailHelper.blockLightbox();

    blockHelper.block();

    blockLightboxHelper.waitOpen();
    blockLightboxHelper.fill('This is a testing block reason');
    blockLightboxHelper.submit();

    await blockLightboxHelper.waitClose();

    expect($('.block-description').getText()).to.be.eventually.equal('This is a testing block reason');
    expect($('.block-description').isDisplayed()).to.be.eventually.true;

    blockHelper.unblock();

    expect($('.block-description').isDisplayed()).to.be.eventually.false;

    await notifications.success.close();
}

shared.attachmentTesting = async function() {
    let attachmentHelper = detailHelper.attachment();
    let date = Date.now();

    // Uploading attachment
    let attachmentsLength = await attachmentHelper.countAttachments();
    var fileToUpload = commonUtil.uploadFilePath();

    await attachmentHelper.upload(fileToUpload, 'This is the testing name ' + date);
    await browser.sleep(5000);

    // Check set name
    let name = await attachmentHelper.getLastAttachmentName();
    expect(name).to.be.equal('This is the testing name ' + date);

    // Check new length
    let newAttachmentsLength = await attachmentHelper.countAttachments();
    expect(newAttachmentsLength).to.be.equal(attachmentsLength + 1);

    //Drag'n drop
    if (['firefox', 'internet explorer'].indexOf(browser.browserName) === -1) {
        await attachmentHelper.dragLastAttchmentToFirstPosition();
        name = await attachmentHelper.getFirstAttachmentName();
        expect(name).to.be.equal('This is the testing name ' + date);
    }
    // Renaming
    await attachmentHelper.renameLastAttchment('This is the new testing name ' + date);
    name = await attachmentHelper.getLastAttachmentName();
    expect(name).to.be.equal('This is the new testing name ' + date);

    // Deprecating
    let deprecatedAttachmentsLength = await attachmentHelper.countDeprecatedAttachments();
    await attachmentHelper.deprecateLastAttachment();
    let newDeprecatedAttachmentsLength = await attachmentHelper.countDeprecatedAttachments();
    expect(newDeprecatedAttachmentsLength).to.be.equal(deprecatedAttachmentsLength + 1);

    // Show deprecated
    attachmentsLength = await attachmentHelper.countAttachments();
    deprecatedAttachmentsLength = await attachmentHelper.countDeprecatedAttachments();
    await attachmentHelper.showDeprecated();
    await browser.waitForAngular();
    newAttachmentsLength = await attachmentHelper.countAttachments();
    expect(newAttachmentsLength).to.be.equal(attachmentsLength + deprecatedAttachmentsLength);

    // Gallery
    attachmentHelper.gallery();

    let countImages = await attachmentHelper.galleryImages().count();

    commonUtil.takeScreenshot('attachments', 'gallery');

    expect(countImages).to.be.above(0);

    attachmentHelper.list();

    // Deleting
    attachmentsLength = await attachmentHelper.countAttachments();
    await attachmentHelper.deleteLastAttachment();
    newAttachmentsLength = await attachmentHelper.countAttachments();
    expect(newAttachmentsLength).to.be.equal(attachmentsLength - 1);
}

shared.deleteTesting = async function() {
    let deleteHelper = detailHelper.delete();
    await deleteHelper.delete();
}

shared.watchersTesting = function() {
    before(function () {
        let watchersHelper = detailHelper.watchers();
        return watchersHelper.removeAllWatchers();
    });

    it('add watcher', async function() {
        let watchersHelper = detailHelper.watchers();
        let watchersLightboxHelper = detailHelper.watchersLightbox();
        let userNames = await watchersHelper.getWatchersUserNames();

        await watchersHelper.addWatcher();
        await watchersLightboxHelper.waitOpen();

        let newWatcherName = await watchersLightboxHelper.getFirstName();

        await watchersLightboxHelper.selectFirst();
        await watchersLightboxHelper.waitClose();

        let newUserNames = await watchersHelper.getWatchersUserNames();

        await userNames.push(newWatcherName);

        expect(newUserNames.join(',')).to.be.equal(userNames.join(','));
    });

    it('clear watcher', async function() {
        let watchersHelper = detailHelper.watchers();

        await watchersHelper.removeAllWatchers();

        let newUserNames = await watchersHelper.getWatchersUserNames();

        expect(newUserNames.join()).to.be.equal('');
    });

    it('filter watcher', async function () {
        let watchersHelper = detailHelper.watchers();
        let watchersLightboxHelper = detailHelper.watchersLightbox();
        let userNames = await watchersHelper.getWatchersUserNames();

        await watchersHelper.addWatcher();
        await watchersLightboxHelper.waitOpen();

        let names = await watchersLightboxHelper.getNames();

        await watchersLightboxHelper.filter(names[0]);

        let newNames = await watchersLightboxHelper.getNames();

        expect(newNames).to.have.length(1);

        await watchersLightboxHelper.selectFirst();
        await watchersLightboxHelper.waitClose();
        await notifications.success.close();
    });

    it('keyboard navigatin', async function() {
        let watchersHelper = detailHelper.watchers();
        let watchersLightboxHelper = detailHelper.watchersLightbox();

        await watchersHelper.addWatcher();
        await watchersLightboxHelper.waitOpen();

        browser
           .actions()
           .sendKeys(protractor.Key.ARROW_DOWN)
           .sendKeys(protractor.Key.ARROW_DOWN)
           .sendKeys(protractor.Key.ARROW_DOWN)
           .sendKeys(protractor.Key.ARROW_UP)
           .perform();

        let selected = watchersLightboxHelper.userList().get(1);

        let isSelected = await commonUtil.hasClass(selected, 'selected');

        expect(isSelected).to.be.true;

        watchersLightboxHelper.close();

        await watchersLightboxHelper.waitClose();
    });
}

shared.customFields = function(typeIndex) {
    before(async function() {
        let url = await browser.getCurrentUrl();
        let rootUrl = await commonUtil.getProjectUrlRoot();
        browser.get(rootUrl + '/admin/project-values/custom-fields');

        await customFieldsHelper.create(typeIndex, 'detail-test-custom-fields-text', 'desc1', 1);

        // debounce :(
        await browser.sleep(2000);

        await customFieldsHelper.create(typeIndex, 'detail-test-custom-fields-multi', 'desc1', 3);

        // debounce :(
        await browser.sleep(2000);

        browser.get(url);

        await commonUtil.waitLoader();
    });

    it('text create', async function() {
        let customFields = customFieldsHelper.getDetailFields();

        // await browser.sleep(4000);
        let count = await customFields.count();

        let textField = customFields.get(count - 2);

        textField.$('input').sendKeys('test text');
        textField.$('.icon-floppy').click();

        // debounce
        await browser.sleep(2000);

        let fieldText = textField.$('.custom-field-value span').getText();

        expect(fieldText).to.be.eventually.equal('test text');
    });

    it('text edit', async function() {
        let customFields = customFieldsHelper.getDetailFields();
        let count = await customFields.count();

        let textField = customFields.get(count - 2);

        textField.$('.icon-edit').click();

        textField.$('input').sendKeys('test text edit');
        textField.$('.icon-floppy').click();

        // debounce
        await browser.sleep(2000);

        let fieldText = textField.$('.custom-field-value span').getText();

        expect(fieldText).to.be.eventually.equal('test text edit');
    });

    it('multi', async function() {
        let customFields = customFieldsHelper.getDetailFields();
        let count = await customFields.count();

        let textField = customFields.get(count - 1);

        textField.$('textarea').sendKeys('test text2');
        textField.$('.icon-floppy').click();

        // debounce
        await browser.sleep(2000);

        let fieldText = textField.$('.custom-field-value span').getText();

        expect(fieldText).to.be.eventually.equal('test text2');
    });

    it('multi edit', async function() {
        let customFields = customFieldsHelper.getDetailFields();
        let count = await customFields.count();

        let textField = customFields.get(count - 1);

        textField.$('.icon-edit').click();
        textField.$('textarea').sendKeys('test text2 edit');
        textField.$('.icon-floppy').click();

        // // debounce
        await browser.sleep(2000);
        let fieldText = await textField.$('.custom-field-value span').getText();

        expect(fieldText).to.be.equal('test text2 edit');
    });
};
