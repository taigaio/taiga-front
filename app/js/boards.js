/*
 * This source code is licensed under the terms of the
 * GNU Affero General Public License found in the LICENSE file in
 * the root directory of this source tree.
 *
 * Copyright (c) 2021-present Kaleidos INC
 */

function initBoard() {
    var eventsCallback = function() {};
    var kanbanStatusObservers = {};

    return {
        events: function(cb) {
            eventsCallback = cb;
        },
        addCard: function(card, statusId, swimlaneId) {
            if (swimlaneId) {
                kanbanStatusObservers[swimlaneId][statusId].observe(card);
            } else {
                kanbanStatusObservers[statusId].observe(card);
            }
        },
        addSwimlane: function(column, statusId, swimlaneId) {
            var options = {
                root: column,
                rootMargin: '0px',
                threshold: 0
            }

            var callback = function(entries) {
                entries = entries.map((entry) => {
                    return {
                        id: Number(entry.target.dataset.id),
                        visible: entry.isIntersecting
                    };
                }).filter((entry) => {
                    return entry.visible
                });

                if (entries.length) {
                    eventsCallback('SHOW_CARD', entries);
                }
            };

            if (swimlaneId) {
                if (!kanbanStatusObservers[swimlaneId]) {
                    kanbanStatusObservers[swimlaneId] = {};
                }

                kanbanStatusObservers[swimlaneId][statusId] = new IntersectionObserver(callback, options);
            } else {
                if (!kanbanStatusObservers[statusId]) {
                    kanbanStatusObservers[statusId] = new IntersectionObserver(callback, options);
                }
            }
        },
    }
}
