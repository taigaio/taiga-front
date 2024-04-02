/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

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
            utils.common.takeScreenshot('memberships', 'add-new-member');
        });

        it('add contacts', async function() {
            newMemberLightbox.addSuggested(0);
            newMemberLightbox.addNew();
            newMemberLightbox.newEmail('xxx' + new Date().getTime() + '@xx.es');
            newMemberLightbox.addNew();
            newMemberLightbox.newEmail('xxx' + new Date().getTime() + '@xx.es');
            utils.common.takeScreenshot('memberships', 'add-new-member-form');
        });

        it('delete members row', async function() {
            newMemberLightbox.deleteInvited(2);

            let invitedRows = await newMemberLightbox.getInviteds().count();

            expect(invitedRows).to.be.equal(2);
        });

        it('set roles', async function() {
            newMemberLightbox.setRole(0);
            newMemberLightbox.setRole(1);
            utils.common.takeScreenshot('memberships', 'add-new-member-form-active');
        });

        it('submit', async function() {
            await browser.sleep(1000);
            await newMemberLightbox.submit();

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

        await utils.notifications.success.open();
        await utils.notifications.success.close();
    });

    it('trying to delete owner', async function() {
        let member = await adminMembershipsHelper.getOwner();

        adminMembershipsHelper.delete(member);

        utils.common.takeScreenshot('memberships', 'delete-owner-lb');

        let isLeaveProjectWarningOpen = await adminMembershipsHelper.isLeaveProjectWarningOpen();
        expect(isLeaveProjectWarningOpen).to.be.equal(true);

        let lb = adminMembershipsHelper.leavingProjectWarningLb();
        await utils.lightbox.open(lb);

        utils.lightbox.exit(lb);

        let isPresent = await lb.isPresent();
        expect(isPresent).to.be.false;
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
