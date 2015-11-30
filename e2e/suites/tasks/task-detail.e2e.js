var utils = require('../../utils');
var taskDetailHelper = require('../../helpers').taskDetail;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('Task detail', function(){
    let taskUrl = '';

    before(async function(){
        await utils.nav
            .init()
            .project('Project Example 0')
            .backlog()
            .taskboard(0)
            .task(0)
            .go();

        taskUrl = await browser.driver.getCurrentUrl();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("tasks", "detail");
    });

    it('title edition', utils.detail.titleTesting);

    it('tags edition', utils.detail.tagsTesting);

    it('description edition', utils.detail.descriptionTesting);

    it('status edition', utils.detail.statusTesting);

    describe('assigned to edition', utils.detail.assignedToTesting);

    describe('watchers edition', utils.detail.watchersTesting);

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

    it('attachments', utils.detail.attachmentTesting);

    describe('custom-fields', utils.detail.customFields.bind(this, 1));

    it('screenshot', async function() {
        await utils.common.takeScreenshot("tasks", "detail updated");
    });

    describe('delete & redirect', function() {
        it('delete', utils.detail.deleteTesting);

        it('redirected', async function (){
            let url = await browser.getCurrentUrl();
            expect(url).not.to.be.equal(taskUrl);
        });
    });
});
