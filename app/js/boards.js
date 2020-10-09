function initBoard() {
    function kanbanColumnObserver() {
        var kanbanColumns = document.querySelectorAll('.taskboard-column');
        var observers = {};

        kanbanColumns.forEach(function(kanbanColumn) {
            var statusId = Number(kanbanColumn.dataset.statusId);
            var swimlaneId = Number(kanbanColumn.dataset.swimlane);
            var options = {
                root: kanbanColumn,
                rootMargin: '0px',
                threshold: 0
            }

            var callback = function(entries) {
                entries.forEach(function(entry) {
                        eventsCallback('SHOW_CARD', {
                            id: Number(entry.target.dataset.id),
                            visible: entry.isIntersecting
                        });
                    });
            };

            if (swimlaneId) {
                if (!observers[swimlaneId]) {
                    observers[swimlaneId] = {};
                }

                observers[swimlaneId][statusId] = new IntersectionObserver(callback, options);
            } else {
                observers[statusId] = new IntersectionObserver(callback, options);
            }
        })

        return observers;
    }

    var eventsCallback = function() {};
    var kanbanStatusObservers = {};

    return {
        events: function(cb) {
            eventsCallback = cb;
        },
        addCard: function(card) {
            var column = card.closest('.taskboard-column');
            var statusId = Number(column.dataset.statusId);
            var swimlaneId = Number(column.dataset.swimlane);

            if (swimlaneId) {
                kanbanStatusObservers[swimlaneId][statusId].observe(card);
            } else {
                kanbanStatusObservers[statusId].observe(card);
            }
        },
        start: function() {
            kanbanStatusObservers = kanbanColumnObserver();
        }
    }
}
