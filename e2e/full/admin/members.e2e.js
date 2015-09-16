var utils = require('../../utils');

var adminMembershipsHelper = require('../../helpers').adminMemberships;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe.only('admin - members', function() {
    before(async function(){
        browser.get('http://localhost:9001/project/project-0/admin/memberships');

        await utils.common.waitLoader();

        utils.common.takeScreenshot('memberships', 'memberships');
    });

    describe('new member', async function() {
        let initMembersCount = 0;
        let newMemberLightbox = null;

        before(async function() {
            initMembersCount = await adminMembershipsHelper.getMembers().count();

            newMemberLightbox = adminMembershipsHelper.getNewMemberLightbox();
            adminMembershipsHelper.openNewMemberLightbox();

            await newMemberLightbox.waitOpen();
            utils.common.takeScreenshot('memberships', 'new-member');
        });

        it('add members row', async function() {
            newMemberLightbox.newEmail('xxx' + new Date().getTime() + '@xx.es');
            newMemberLightbox.newEmail('xxx' + new Date().getTime() + '@xx.es');
            newMemberLightbox.newEmail('xxx' + new Date().getTime() + '@xx.es');

            let membersRows = await newMemberLightbox.getRows().count();

            expect(membersRows).to.be.equal(3 + 1);
        });

        it('delete members row', async function() {
            newMemberLightbox.deleteRow(2);

            let membersRows = await newMemberLightbox.getRows().count();

            expect(membersRows).to.be.equal(2 + 1);
        });

        it('submit', async function() {
            newMemberLightbox.submit();

            await newMemberLightbox.waitClose();

            let members = adminMembershipsHelper.getMembers();
            let membersCount = await members.count();

            expect(membersCount).to.be.equal(initMembersCount + 2);
        });

        it('the last two should be pending', async function() {
            let members = adminMembershipsHelper.getMembers();
            let membersCount = await members.count();

            let lastMember1 = members.get(membersCount - 1);
            let lastMember2 = members.get(membersCount - 2);

            let active1 = await adminMembershipsHelper.isActive(lastMember1);
            let active2 = await adminMembershipsHelper.isActive(lastMember2);

            expect(active1).to.be.false;
            expect(active2).to.be.false;
        });
    });

    it('delete member', async function() {
        let initMembersCount = await adminMembershipsHelper.getMembers().count();

        let member = adminMembershipsHelper.getMembers().last();

        adminMembershipsHelper.delete(member);

        utils.common.takeScreenshot('memberships', 'delete-member-lb');

        await utils.lightbox.confirm.ok();

        let membersCount = await adminMembershipsHelper.getMembers().count();

        expect(membersCount).to.be.equal(initMembersCount - 1);
    });

    it('change role', async function() {
        let member = adminMembershipsHelper.getMembers().last();

        adminMembershipsHelper.setRole(member, 3);

        expect(utils.notifications.success.open()).to.be.eventually.true;
    });

    it('resend invitation', async function() {
        let member = adminMembershipsHelper.getMembers().last();

        adminMembershipsHelper.sendInvitation();

        expect(utils.notifications.success.open()).to.be.eventually.true;
    });

    it('toggle admin', async function() {
        let member = adminMembershipsHelper.getMembers().last();
        let isAdmin =  await adminMembershipsHelper.isAdmin(member);

        if (isAdmin) {
            adminMembershipsHelper.toggleAdmin(member);

            await browser.waitForAngular();
            isAdmin =  await adminMembershipsHelper.isAdmin(member);

            expect(isAdmin).not.to.be.true;
        }

        adminMembershipsHelper.toggleAdmin(member);

        await utils.notifications.success.open();

        isAdmin =  await adminMembershipsHelper.isAdmin(member);

        expect(isAdmin).to.be.true;

        await utils.notifications.success.close();
    });

});
