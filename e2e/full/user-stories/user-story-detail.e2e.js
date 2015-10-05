var utils = require('../../utils');
var usDetailHelper = require('../../helpers').usDetail;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('User story detail', function(){
    let usUrl = '';

    before(async function(){
        utils.nav
            .init()
            .project(0)
            .backlog()
            .us(0)
            .go();

        usUrl = await browser.getCurrentUrl();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("user-stories", "detail");
    });

    it('title edition', utils.detail.titleTesting);

    it('tags edition', utils.detail.tagsTesting);

    it('description edition', utils.detail.descriptionTesting);

    it('status edition', utils.detail.statusTesting);

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

    it('attachments', utils.detail.attachmentTesting);

    describe('custom-fields', utils.detail.customFields.bind(this, 0));

    describe('related tasks', function() {
        it('create', async function() {
            let oldRelatedTaskCount = await usDetailHelper.relatedTasks().count();

            usDetailHelper.createRelatedTasks('test', 1, 1);

            expect(utils.notifications.success.open()).to.be.eventually.true;

            let relatedTaskCount = usDetailHelper.relatedTasks().count();

            expect(relatedTaskCount).to.be.eventually.equal(oldRelatedTaskCount + 1);
        });

        it('edit', function() {
            usDetailHelper.editRelatedTasks(0, 'test2', 2, 2);

            expect(utils.notifications.success.open()).to.be.eventually.true;
        });

        it('delete', async function() {
            let oldRelatedTaskCount = await usDetailHelper.relatedTasks().count();

            usDetailHelper.deleteRelatedTask(0);

            expect(utils.notifications.success.open()).to.be.eventually.true;

            let relatedTaskCount = usDetailHelper.relatedTasks().count();

            expect(relatedTaskCount).to.be.eventually.equal(oldRelatedTaskCount - 1);
        });
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("user-stories", "detail updated");
    });

    describe('delete & redirect', function() {
        it('delete', utils.detail.deleteTesting);

        it('redirected', async function (){
            let url = await browser.getCurrentUrl();
            expect(url).not.to.be.equal(usUrl);
        });
    });
})
