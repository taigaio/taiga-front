var utils = require('../../utils');
var usDetailHelper = require('../../helpers').usDetail;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe.only('User story detail', function(){
    let backlogUrl = "";
    before(async function(){
        await utils.common.goHome();
        await utils.common.goToFirstProject();
        await utils.common.goToBacklog();
        backlogUrl = await browser.getCurrentUrl();
        await utils.common.goToFirstUserStory();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("user-stories", "detail");
    });

    it('title edition', utils.detail.titleTesting);

    it('tags edition', utils.detail.tagsTesting);

    it('description edition', utils.detail.descriptionTesting);

    it('assigned to edition', utils.detail.assignedToTesting);

    it('team requirement edition', async function() {
      let requirementHelper = usDetailHelper.teamRequirement();
      let isRequired = await requirementHelper.isRequired();

      // Toggle
      requirementHelper.toggleStatus();
      let newIsRequired = await requirementHelper.isRequired();
      expect(isRequired).to.be.not.equal(newIsRequired);

      // Toggle again
      requirementHelper.toggleStatus();
      newIsRequired = await requirementHelper.isRequired();
      expect(isRequired).to.be.equal(newIsRequired);
    });

    it('client requirement edition', async function() {
      let requirementHelper = usDetailHelper.clientRequirement();
      let isRequired = await requirementHelper.isRequired();

      // Toggle
      requirementHelper.toggleStatus();
      let newIsRequired = await requirementHelper.isRequired();
      expect(isRequired).to.be.not.equal(newIsRequired);

      // Toggle again
      requirementHelper.toggleStatus();
      newIsRequired = await requirementHelper.isRequired();
      expect(isRequired).to.be.equal(newIsRequired);
    });

    it('watchers edition', utils.detail.watchersTesting);

    it('history', utils.detail.historyTesting);

    it('block', utils.detail.blockTesting);

    it('attachments', utils.detail.attachmentTesting)

    it('screenshot', async function() {
        await utils.common.takeScreenshot("user-stories", "detail updated");
    });

    it('delete', utils.detail.deleteTesting);

    it('redirected', async function (){
        let url = await browser.getCurrentUrl();
        expect(url.endsWith(backlogUrl+"?no-milestone=1")).to.be.true;
    });
})
