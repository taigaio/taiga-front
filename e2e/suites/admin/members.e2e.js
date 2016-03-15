var utils = require('../../utils');

var adminMembershipsHelper = require('../../helpers').adminMemberships;

var chai = require('chai');
var chaiAsPromised = require('chai-as-promised');

chai.use(chaiAsPromised);
var expect = chai.expect;

describe('admin - members', function() {
    before(async function(){
        browser.get(browser.params.glob.host + 'project/project-0/admin/memberships');

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

        let member = adminMembershipsHelper.excludeOwner(adminMembershipsHelper.getMembers()).last();

        adminMembershipsHelper.delete(member);

        utils.common.takeScreenshot('memberships', 'delete-member-lb');

        await utils.lightbox.confirm.ok();

        let membersCount = await adminMembershipsHelper.getMembers().count();

        expect(membersCount).to.be.equal(initMembersCount - 1);

        await utils.notifications.success.close();
    });

    it('trying to delete owner', async function() {
        let member = await adminMembershipsHelper.getOwner();

        adminMembershipsHelper.delete(member);

        utils.common.takeScreenshot('memberships', 'delete-owner-lb');

        let isLeaveProjectWarningOpen = await adminMembershipsHelper.isLeaveProjectWarningOpen();

        expect(isLeaveProjectWarningOpen).to.be.equal(true);

        let lb = adminMembershipsHelper.leavingProjectWarningLb();

        await utils.lightbox.exit(lb);
        await utils.lightbox.close(lb);
    });

    it('change role', async function() {
        let member = adminMembershipsHelper.getMembers().last();

        //prevent change to the same value
        adminMembershipsHelper.setRole(member, 1);
        adminMembershipsHelper.setRole(member, 3);
        adminMembershipsHelper.setRole(member, 2);

        expect(utils.notifications.success.open()).to.be.eventually.true;

        await utils.notifications.success.close();
    });

    it('resend invitation', async function() {
        let member = adminMembershipsHelper.getMembers().last();

        adminMembershipsHelper.sendInvitation(member);

        expect(utils.notifications.success.open()).to.be.eventually.true;

        await utils.notifications.success.close();
    });

    it('toggle admin', async function() {
        let member = adminMembershipsHelper.getMembers().get(1);
        let isAdmin =  await adminMembershipsHelper.isAdmin(member);

        if (isAdmin) {
            adminMembershipsHelper.toggleAdmin(member);

            await utils.notifications.success.open();

            isAdmin =  await adminMembershipsHelper.isAdmin(member);

            expect(isAdmin).not.to.be.true;
        } else {
            adminMembershipsHelper.toggleAdmin(member);

            await utils.notifications.success.open();

            isAdmin =  await adminMembershipsHelper.isAdmin(member);

            expect(isAdmin).to.be.true;
        }

        await utils.notifications.success.close();
    });

});
