var path = require('path');
var detailHelper = require('../helpers').detail;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

var helper = module.exports;

helper.titleTesting = async function() {
    let titleHelper = detailHelper.title();
    let title = await titleHelper.getTitle();
    let date = Date.now();
    titleHelper.setTitle("New title " + date);
    let newTitle = await titleHelper.getTitle();
    expect(newTitle).to.be.not.equal(title);
}

helper.tagsTesting = async function() {
    let tagsHelper = detailHelper.tags();
    let tagsText = await tagsHelper.getTagsText();
    await tagsHelper.clearTags();
    let date = Date.now();
    let tags = [1, 2, 3, 4, 5].map((i) => date + "-" + i);
    tagsHelper.addTags(tags);
    await browser.waitForAngular();
    let newtagsText = await tagsHelper.getTagsText();
    expect(newtagsText).to.be.not.equal(tagsText);
}

helper.descriptionTesting = async function() {
    let descriptionHelper = detailHelper.description();
    let description = await descriptionHelper.getInnerHtml();
    let date = Date.now();
    descriptionHelper.enabledEditionMode();
    descriptionHelper.setText("New description " + date);
    descriptionHelper.save();
    let newDescription = await descriptionHelper.getInnerHtml();
    expect(newDescription).to.be.not.equal(description);
}

helper.statusTesting = async function() {
    let statusHelper = detailHelper.statusSelector();

    // Current status
    let selectedStatus = await statusHelper.getSelectedStatus();
    let genericStatus = await statusHelper.getGeneralStatus();
    expect(selectedStatus).to.be.equal(genericStatus);

    // Status 1
    await statusHelper.setStatus(1);

    selectedStatus = await statusHelper.getSelectedStatus();
    genericStatus = await statusHelper.getGeneralStatus();
    expect(selectedStatus).to.be.equal(genericStatus);

    // Status 2
    await statusHelper.setStatus(2);

    let newSelectedStatus = await statusHelper.getSelectedStatus();
    let newGenericStatus = await statusHelper.getGeneralStatus();
    expect(newSelectedStatus).to.be.equal(newGenericStatus);
    expect(newSelectedStatus).to.be.not.equal(selectedStatus);
    expect(newGenericStatus).to.be.not.equal(genericStatus);
}

helper.assignedToTesting = async function() {
    let assignedTo = detailHelper.assignedTo();
    let assignToLightbox = detailHelper.assignToLightbox();
    let userName = detailHelper.assignedTo().getUserName();
    await assignedTo.clear();
    assignedTo.assign();
    assignToLightbox.waitOpen();
    assignToLightbox.selectFirst();
    assignToLightbox.waitClose();
    let newUserName = assignedTo.getUserName();
    expect(newUserName).to.be.not.equal(userName);
}

helper.historyTesting = async function() {
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

helper.blockTesting = function() {
    let blockHelper = detailHelper.block();
    let blockLightboxHelper = detailHelper.blockLightbox();
    blockHelper.block();
    blockLightboxHelper.waitOpen();
    blockLightboxHelper.fill('This is a testing block reason');
    blockLightboxHelper.submit();
    blockLightboxHelper.waitClose();
    expect($('.block-description').getText()).to.be.eventually.equal('This is a testing block reason');
    expect($('.block-description').isDisplayed()).to.be.eventually.true;
    blockHelper.unblock();
    expect($('.block-description').isDisplayed()).to.be.eventually.false;
}

helper.attachmentTesting = async function() {
    let attachmentHelper = detailHelper.attachment();
    let date = Date.now();

    // Uploading attachment
    let attachmentsLength = await attachmentHelper.countAttachments();
    var fileToUpload = './upload-file-test.txt',
    absolutePath = path.resolve(process.cwd(), 'e2e', fileToUpload);
    await attachmentHelper.upload(absolutePath, 'This is the testing name ' + date);

    // Check set name
    let name = await attachmentHelper.getLastAttachmentName();
    expect(name).to.be.equal('This is the testing name ' + date);
    // Check new length
    let newAttachmentsLength = await attachmentHelper.countAttachments();
    expect(newAttachmentsLength).to.be.equal(attachmentsLength + 1);

    //Drag'n drop
    await attachmentHelper.dragLastAttchmentToFirstPosition();
    name = await attachmentHelper.getFirstAttachmentName();
    expect(name).to.be.equal('This is the testing name ' + date);

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

    // Deleting
    attachmentsLength = await attachmentHelper.countAttachments();
    await attachmentHelper.deleteLastAttachment();
    newAttachmentsLength = await attachmentHelper.countAttachments();
    expect(newAttachmentsLength).to.be.equal(attachmentsLength - 1);
}

helper.deleteTesting = async function() {
    let deleteHelper = detailHelper.delete();
    await deleteHelper.delete();
}

helper.watchersTesting = async function() {
    let watchersHelper = detailHelper.watchers();
    let watchersLightboxHelper = detailHelper.watchersLightbox();
    let userNames = await watchersHelper.getWatchersUserNames();

    //Add watcher
    watchersHelper.addWatcher();
    watchersLightboxHelper.waitOpen();
    watchersLightboxHelper.selectFirst();
    watchersLightboxHelper.waitClose();

    let newUserNames = await watchersHelper.getWatchersUserNames();
    expect(newUserNames.join()).to.be.equal(userNames + ',Administrator');

    //Clear watchers
    await watchersHelper.removeAllWathchers();
    newUserNames = await watchersHelper.getWatchersUserNames();
    expect(newUserNames.join()).to.be.equal('');
}
