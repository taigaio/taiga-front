/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../utils');
var sharedDetail = require('../../shared/detail');
var epicDetailHelper = require('../../helpers').epicDetail;
var wysiwyg = require('../../shared/wysiwyg');
var sharedWysiwyg = wysiwyg.wysiwygTesting;
var sharedWysiwygComments = wysiwyg.wysiwygTestingComments;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('Epic detail', async function(){
    let epicUrl = '';

    before(async function(){
        await utils.nav
            .init()
            .project('Project Example 0')
            .epics()
            .epic(0)
            .go();

        epicUrl = await browser.getCurrentUrl();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("epics", "detail");
    });

    it('color edition', async function() {
      let colorEditor = epicDetailHelper.colorEditor();
      await colorEditor.open();
      await colorEditor.selectFirstColor();
      await colorEditor.open();
      await colorEditor.selectLastColor();
      await utils.common.takeScreenshot("epics", "detail color updated");
    });

    it('title edition', sharedDetail.titleTesting);

    it('tags edition', sharedDetail.tagsTesting);

    describe('description', sharedWysiwyg.bind(this, '.duty-content'));

    describe('related userstories', function() {
        let relatedUserstories = epicDetailHelper.relatedUserstories();
        it('create new user story', async function(){
            await relatedUserstories.createNewUserStory("Testing subject");
        });

        it('create new user stories in bulk', async function(){
            await relatedUserstories.createNewUserStories("Testing subject1\nTesting subject 2");
        });

        it('add related userstory', async function(){
            await relatedUserstories.selectFirstRelatedUserstory();
        });

        it('delete related userstory', async function(){
            await relatedUserstories.deleteFirstRelatedUserstory();
        })
    });

    it('status edition', sharedDetail.statusTesting.bind(this, 'Ready', 'In progress'));

    describe('assigned to edition', sharedDetail.assignedToTesting);

    describe('watchers edition', sharedDetail.watchersTesting);

    it('history', sharedDetail.historyTesting.bind(this, "epics"));

    describe('comments epics', sharedWysiwygComments.bind(this, '.comments', 'epics'));

    it('block', sharedDetail.blockTesting);

    describe('team requirement edition', sharedDetail.teamRequirementTesting);

    describe('client requirement edition', sharedDetail.clientRequirementTesting);

    it('attachments', sharedDetail.attachmentTesting);

    describe('custom-fields', sharedDetail.customFields.bind(this, 0));

    it('screenshot', async function() {
        await utils.common.takeScreenshot("epics", "detail updated");
    });

    describe('delete & redirect', function() {
        it('delete', sharedDetail.deleteTesting);

        it('redirected', async function (){
            let url = await browser.getCurrentUrl();
            expect(url).not.to.be.equal(epicUrl);
        });
    });

});


/*
TODO:
# Related user stories
*/
