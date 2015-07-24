var detailHelper = require('../helpers').detail;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

var helper = module.exports;

helper.assignedToTesting = async function() {
    let assignedTo = detailHelper.assignedTo();
    let assignToLightbox = detailHelper.assignToLightbox();

    let userName = detailHelper.assignedTo().getUserName();
    await assignedTo.clear();
    assignedTo.assign();
    assignToLightbox.waitOpen();
    assignToLightbox.selectFirst();
    assignToLightbox.waitClose();
    let newUserName = assignedTo.getUserName();
    expect(newUserName).to.be.not.equal(userName);
}
