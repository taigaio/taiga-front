/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../../utils');
var epicsDashboardHelper = require('../../helpers').epicsDashboard;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('Epics Dashboard', function(){
    let epicsUrl = '';

    before(async function(){
        await utils.nav
            .init()
            .project('Project Example 0')
            .epics()
            .go();

        epicsUrl = await browser.getCurrentUrl();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("epics", "dashboard");
    });

    it('display child stories', async function() {
        let epic = epicsDashboardHelper.epic();
        let childStoriesNum = await epic.displayUserStoriesinEpic();
        expect(childStoriesNum).to.be.above(0);
    });

    it('create Epic', async function() {
        let date = Date.now();
        let description = Math.random().toString(36).substring(7);
        let epic = epicsDashboardHelper.epic();
        let currentEpicsNum = await epic.getEpics();
        await epic.createEpic(date, description);
        let newEpicsNum = await epic.getEpics();
        expect(newEpicsNum).to.be.above(currentEpicsNum);
    });

    it('change epic assigned from dashboard', async function() {
        let epic = epicsDashboardHelper.epic();
        await epic.resetAssignedTo();
        let currentAssigned = await epic.getAssignedTo();
        await epic.editAssignedTo();
        let newAssigned = await epic.getAssignedTo();
        expect(currentAssigned).to.be.not.equal(newAssigned);
    });

    it('remove assigned from dashboard', async function() {
        let epic = epicsDashboardHelper.epic();
        await epic.resetAssignedTo();
        let unAssigned = await epic.removeAssignedTo();
        expect(unAssigned).to.be.equal('Unassigned');
    });

    it('change status from dashboard', async function() {
        let epic = epicsDashboardHelper.epic();
        await epic.resetStatus();
        let currentStatus = await epic.getStatus();
        await epic.editStatus();
        let newStatus = await epic.getStatus();
        expect(currentStatus).to.be.not.equal(newStatus);
    });

    it('remove columns from dashboard', async function() {
        let epic = epicsDashboardHelper.epic();
        let currentColumns = await epic.getColumns();
        await epic.removeColumns();
        let newColumns = await epic.getColumns();
        expect(currentColumns).to.be.above(newColumns);
    });

})
