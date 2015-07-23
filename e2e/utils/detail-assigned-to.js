var detailAssignedToHelper = require('../helpers').detailAssignedTo;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

var helper = module.exports;

helper.assignedToTesting = async function() {
    let assignedTo = detailAssignedToHelper.assignedTo();
    let assignToLightbox = detailAssignedToHelper.assignToLightbox();

    let userName = detailAssignedToHelper.assignedTo().getUserName();
    await assignedTo.clear();
    assignedTo.assign();
    assignToLightbox.waitOpen();
    assignToLightbox.selectFirst();
    assignToLightbox.waitClose();
    let newUserName = assignedTo.getUserName();
    expect(newUserName).to.be.not.equal(userName);
}
