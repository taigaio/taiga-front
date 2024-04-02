/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../utils');
var sharedDetail = require('../../shared/detail');
var taskDetailHelper = require('../../helpers').taskDetail;
var wysiwyg = require('../../shared/wysiwyg');
var sharedWysiwyg = wysiwyg.wysiwygTesting;
var sharedWysiwygComments = wysiwyg.wysiwygTestingComments;

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

    it('title edition', sharedDetail.titleTesting);

    it('tags edition', sharedDetail.tagsTesting);

    describe('description', sharedWysiwyg.bind(this, '.duty-content'));

    it('status edition', sharedDetail.statusTesting.bind(this, 'In progress', 'Ready for test'));

    describe('assigned to edition', sharedDetail.assignedToTesting);

    describe('watchers edition', sharedDetail.watchersTesting);

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

    it('history', sharedDetail.historyTesting.bind(this, "tasks"));

    describe('comments task', sharedWysiwygComments.bind(this, '.comments', 'tasks'));

    it('block', sharedDetail.blockTesting);

    it('attachments', sharedDetail.attachmentTesting);

    describe('custom-fields', sharedDetail.customFields.bind(this, 2));

    it('screenshot', async function() {
        await utils.common.takeScreenshot("tasks", "detail updated");
    });

    describe('delete & redirect', function() {
        it('delete', sharedDetail.deleteTesting);

        it('redirected', async function (){
            let url = await browser.getCurrentUrl();
            expect(url).not.to.be.equal(taskUrl);
        });
    });
});
