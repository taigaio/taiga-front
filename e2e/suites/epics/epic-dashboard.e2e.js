var utils = require('../../utils');
var epicsHelper = require('../../helpers/epics-helper');

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('Epics Dashboard', function(){
    let usUrl = '';

    before(async function(){
        await utils.nav
            .init()
            .project('Project Example 0')
            .epics()
            .go();

        usUrl = await browser.getCurrentUrl();
    });

    it('screenshot', async function() {
        await utils.common.takeScreenshot("epics", "dashboard");
    });

    it('display child stories', async function() {
        let epic = epicsHelper.epic();
        let childStoriesNum = await epic.displayUserStoriesinEpic();
        expect(childStoriesNum).to.be.above(0);
    });

    it('change epic assigned from dashboard', async function() {
        let epic = epicsHelper.epic();
        await epic.resetAssignedTo();
        let currentAssigned = await epic.getAssignedTo();
        await epic.editAssignedTo();
        let newAssigned = await epic.getAssignedTo();
        expect(currentAssigned).to.be.not.equal(newAssigned);
    });

    it('remove assigned from dashboard', async function() {
        let epic = epicsHelper.epic();
        await epic.resetAssignedTo();
        let unAssigned = await epic.removeAssignedTo();
        console.log(unAssigned);
        expect(unAssigned).to.be.equal('Unassigned');
    });

    it('change status from dashboard', async function() {
        let epic = epicsHelper.epic();
        await epic.resetStatus();
        let currentStatus = await epic.getStatus();
        await epic.editStatus();
        let newStatus = await epic.getStatus();
        expect(currentStatus).to.be.not.equal(newStatus);
    });

    it('remove columns from dashboard', async function() {
        let epic = epicsHelper.epic();
        let currentColumns = await epic.getColumns();
        await epic.removeColumns();
        let newColumns = await epic.getColumns();
        expect(currentColumns).to.be.above(newColumns);
    });

})
