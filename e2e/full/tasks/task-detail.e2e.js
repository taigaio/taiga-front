var utils = require('../../utils');
var taskDetailHelper = require('../../helpers').taskDetail;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('Task detail', function(){
    let sprintUrl = "";

    before(async function(){
        utils.common.goHome();
        utils.common.goToFirstProject();
        utils.common.goToBacklog();
        utils.common.goToFirstSprint();
        sprintUrl = await browser.getCurrentUrl();
        utils.common.goToFirstTask();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("tasks", "detail");
    });

    it('title edition', utils.detail.titleTesting);

    it('tags edition', utils.detail.tagsTesting);

    it('description edition', utils.detail.descriptionTesting);

    it('assigned to edition', utils.detail.assignedToTesting);

    it('watchers edition', utils.detail.watchersTesting);

    it('iocaine edition', async function() {
      // Toggle iocaine status
      let iocaineHelper = taskDetailHelper.iocaine();
      let isIocaine = await iocaineHelper.isIocaine()
      iocaineHelper.togleIocaineStatus();
      let newIsIocaine = await iocaineHelper.isIocaine()
      expect(newIsIocaine).to.be.not.equal(isIocaine);

      // Toggle again
      iocaineHelper.togleIocaineStatus();
      newIsIocaine = await iocaineHelper.isIocaine()
      expect(newIsIocaine).to.be.equal(isIocaine);
    });

    it('history', utils.detail.historyTesting);

    it('block', utils.detail.blockTesting);

    it('attachments', utils.detail.attachmentTesting)

    it('screenshot', async function() {
        await utils.common.takeScreenshot("tasks", "detail updated");
    });

    it('delete', utils.detail.deleteTesting);

    it('redirected', async function (){
        let url = await browser.getCurrentUrl();
        expect(url.endsWith(sprintUrl)).to.be.true;
    });

})
