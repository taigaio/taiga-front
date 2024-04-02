/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../utils');
var sharedDetail = require('../../shared/detail');
var wysiwyg = require('../../shared/wysiwyg');
var sharedWysiwyg = wysiwyg.wysiwygTesting;
var sharedWysiwygComments = wysiwyg.wysiwygTestingComments;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('Issue detail', async function(){
    let issueUrl = '';

    before(async function(){
        await utils.nav
            .init()
            .project('Project Example 0')
            .issues()
            .issue(0)
            .go();

        issueUrl = await browser.getCurrentUrl();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("issues", "detail");
    });

    it('title edition', sharedDetail.titleTesting);

    it('tags edition', sharedDetail.tagsTesting);

    describe('description', sharedWysiwyg.bind(this, '.duty-content'));

    it('status edition', sharedDetail.statusTesting.bind(this, 'In progress', 'Ready for test'));

    describe('assigned to edition', sharedDetail.assignedToTesting);

    describe('watchers edition', sharedDetail.watchersTesting);

    it('history', sharedDetail.historyTesting.bind(this, "issues"));

    describe('comments issue', sharedWysiwygComments.bind(this, '.comments', 'issues'));

    it('block', sharedDetail.blockTesting);

    it('attachments', sharedDetail.attachmentTesting);

    describe('custom-fields', sharedDetail.customFields.bind(this, 3));

    it('screenshot', async function() {
        await utils.common.takeScreenshot("issues", "detail updated");
    });

    describe('delete & redirect', function() {
        it('delete', sharedDetail.deleteTesting);

        it('redirected', async function (){
            let url = await browser.getCurrentUrl();
            expect(url).not.to.be.equal(issueUrl);
        });
    });

});
