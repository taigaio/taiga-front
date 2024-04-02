/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

var utils = require('../utils');

var helper = module.exports;

helper.liked = function() {
    return $('tg-most-liked');
};

helper.active = function() {
    return $('tg-most-active');
};

helper.featured = function() {
    return $('tg-featured-projects');
};

helper.likedProjects = function() {
    return helper.liked().$$('.highlighted-project');
};

helper.activeProjects = function() {
    return helper.active().$$('.highlighted-project');
};

helper.featuredProjects = function() {
    return helper.featured().$$('.featured-project');
};

helper.rearrangeLike = function(index) {
    helper.liked().$('.current-filter').click();

    helper.liked().$$('.filter-list li').get(index).click();
};

helper.getLikeFilterText = function(index) {
    return helper.liked().$('.current-filter').getText();
};

helper.rearrangeActive = function(index) {
    helper.active().$('.current-filter').click();

    helper.active().$$('.filter-list li').get(index).click();
};

helper.getActiveFilterText = function(index) {
    return helper.active().$('.current-filter').getText();
};

helper.searchFilter = function(index) {
    return $$('.searchbox-filters label').get(index).click();
};

helper.searchProjectsList = function() {
    return $('.project-list');
};

helper.searchProjects = function() {
    return helper.searchProjectsList().$$('li');
};

helper.searchInput = function() {
    return $('.searchbox input');
};

helper.sendSearch = function() {
    return $('.search-button').click();
};

helper.mostLiked = function() {
    $$('.discover-search-filter').get(0).click();
};

helper.mostActived = function() {
    $$('.discover-search-filter').get(1).click();
};

helper.searchOrder = function(index) {
    $$('.filter-list a').get(index).click();
};

helper.orderSelectorWrapper = function() {
    return $('.discover-search-subfilter');
};

helper.clearOrder = function() {
    helper.orderSelectorWrapper().$('.results').click();
};
