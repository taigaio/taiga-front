/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../utils');
var sharedDetail = require('../../shared/detail');
var usDetailHelper = require('../../helpers').usDetail;
var wysiwyg = require('../../shared/wysiwyg');
var sharedWysiwyg = wysiwyg.wysiwygTesting;
var sharedWysiwygComments = wysiwyg.wysiwygTestingComments;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('User story detail', function(){
    let usUrl = '';

    before(async function(){
        await utils.nav
            .init()
            .project('Project Example 0')
            .backlog()
            .us(0)
            .go();

        usUrl = await browser.getCurrentUrl();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("user-stories", "detail");
    });

    it('title edition', sharedDetail.titleTesting);

    it('tags edition', sharedDetail.tagsTesting);

    describe('description', sharedWysiwyg.bind(this, '.duty-content'));

    it('status edition', sharedDetail.statusTesting.bind(this, 'Ready', 'In progress'));

    describe('assigned to edition', sharedDetail.assignedToTesting);

    describe('team requirement edition', sharedDetail.teamRequirementTesting);

    describe('client requirement edition', sharedDetail.clientRequirementTesting);

    describe('watchers edition', sharedDetail.watchersTesting);

    it('history', sharedDetail.historyTesting.bind(this, "user-stories"));

    describe('comments us', sharedWysiwygComments.bind(this, '.comments', 'issues'));

    it('block', sharedDetail.blockTesting);

    it('attachments', sharedDetail.attachmentTesting);

    describe('custom-fields', sharedDetail.customFields.bind(this, 1));

    describe('related tasks', function() {
        it('create', async function() {
            let oldRelatedTaskCount = await usDetailHelper.relatedTasks().count();

            await usDetailHelper.createRelatedTasks('test', 1, 1);

            let relatedTaskCount = await usDetailHelper.relatedTasks().count();

            expect(relatedTaskCount).to.be.equal(oldRelatedTaskCount + 1);
        });

        it('edit', async function() {
            await usDetailHelper.editRelatedTasks(0, 'test2', 2, 2);

            let count = await usDetailHelper.editRelatedTasksEnabled();

            expect(count).to.be.equal.false;
        });

        it('delete', async function() {
            let oldRelatedTaskCount = await usDetailHelper.relatedTasks().count();

            await usDetailHelper.deleteRelatedTask(0);

            let relatedTaskCount = usDetailHelper.relatedTasks().count();

            expect(relatedTaskCount).to.be.eventually.equal(oldRelatedTaskCount - 1);
        });
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("user-stories", "detail updated");
    });

    describe('delete & redirect', function() {
        it('delete', sharedDetail.deleteTesting);

        it('redirected', async function (){
            let url = await browser.getCurrentUrl();
            expect(url).not.to.be.equal(usUrl);
        });
    });
})
