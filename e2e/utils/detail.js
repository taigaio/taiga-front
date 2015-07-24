var detailHelper = require('../helpers').detail;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

var helper = module.exports;

helper.titleTesting = async function() {
    let titleHelper = detailHelper.title();
    let title = await titleHelper.getTitle();
    let date = Date.now()
    titleHelper.setTitle("New title " + date);
    let newTitle = await titleHelper.getTitle();
    expect(newTitle).to.be.not.equal(title);
}

helper.tagsTesting = async function() {
    let tagsHelper = detailHelper.tags();
    let tagsText = await tagsHelper.getTagsText();
    await tagsHelper.clearTags();
    let date = Date.now();
    let tags = [1, 2, 3, 4, 5].map(function(i){ return date + "-" + i})
    tagsHelper.addTags(tags);
    await browser.waitForAngular();
    let newtagsText = await tagsHelper.getTagsText();
    expect(newtagsText).to.be.not.equal(tagsText);
}

helper.descriptionTesting = async function() {
    let descriptionHelper = detailHelper.description();
    let description = await descriptionHelper.getInnerHtml();
    let date = Date.now()
    descriptionHelper.enabledEditionMode();
    descriptionHelper.setText("New description " + date)
    descriptionHelper.save();
    let newDescription = await descriptionHelper.getInnerHtml();
    expect(newDescription).to.be.not.equal(description);
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
    let date = Date.now()
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

helper.deleteTesting = async function() {
    let deleteHelper = detailHelper.delete();
    await deleteHelper.delete();
}
