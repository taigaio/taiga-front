/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');

var helper = module.exports;

helper.team = function() {
  let el = $('.team');

  let obj = {
      el: el,
      firstRole: function() {
        return el.$$('section[tg-team-members] .avatar span').first();
      },

      firstMember: function() {
        return el.$$('section[tg-team-members] a.name').first();
      },

      count: function() {
        return el.$$('section[tg-team-members] .row.member').count();
      },

      leave: function() {
        el.$(".hero .username a").click();
      }
  };

  return obj;
};

helper.filters = function() {
  let el = $('.team-filters-inner');

  let obj = {
      el: el,
      filterByRole: function(roleName) {
        let roles = el.$$("ul li a");
        roles.filter(function(role) {
          return role.getText().then(function(text) {
            return text.toLowerCase() === roleName.toLowerCase();
          });
        }).click();

      },

      clearText: function(text) {
        el.$('input[ng-model="filtersQ"]').clear();
      },

      searchText: function(text) {
        el.$('input[ng-model="filtersQ"]').sendKeys(text);
      }
  };

  return obj;
};

helper.leavingProjectWarningLb = function() {
    return $('div[tg-lightbox-leave-project-warning]');
};

helper.isLeaveProjectWarningOpen = function() {
    return helper.leavingProjectWarningLb().isPresent();
};
