/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (c) 2021-present Kaleidos Ventures SL
 */

(function() {
    var multipleSortableClass = 'ui-multisortable-multiple';
    var mainClass = 'main-drag-item';
    var inProgress = false;
    var removeEventFn = null;

    var reset = function(elm) {
        $(elm)
            .removeAttr('style')
            .removeClass('tg-multiple-drag-mirror')
            .removeClass('multiple-drag-mirror')
            .data('dragMultipleIndex', null)
            .data('dragMultipleActive', false);
    };

    var drag = function() {
        var shadow = dragMultiple.items.shadow;

        // following the drag element
        var currentLeft = shadow.position().left;
        var currentTop = shadow.position().top;
        var height = shadow.outerHeight();

        $('.gu-transit').addClass('gu-transit-multi');

        _.forEach(dragMultiple.items.draggingItems, function(elm, index) {
            var elmIndex = parseInt(elm.data('dragMultipleIndex'), 10);
            var top = currentTop + (elmIndex * height);

            elm
                .css({
                    top: top,
                    left: currentLeft
                });
        });
    };

    var stop = function() {
        inProgress = false;

        refreshOriginal();

        document.documentElement.removeEventListener('mousemove', removeEventFn);

        // reset
        dragMultiple.items = {};

        $('.' + mainClass).removeClass(mainClass);
        $('.tg-multiple-drag-mirror').remove();
        $('.multiple-drag-mirror').removeClass('multiple-drag-mirror');

        $('.tg-multiple-drag-dragging')
            .removeClass('tg-multiple-drag-dragging')
            .show();

        $('.gu-transit-multi').removeClass('gu-transit-multi');

        return $('.' + multipleSortableClass);
    };

    var refreshOriginal = function() {
        var index = parseInt(dragMultiple.items.elm.data('dragMultipleIndex'), 10);

        var after = [];
        var before = [];

        _.forEach(dragMultiple.items.draggedItemsOriginal, function(item) {
            if (parseInt($(item).data('dragMultipleIndex'), 10) > index) {
                after.push(item);
            } else {
                before.push(item);
            }
        });

        after.reverse();

        _.forEach(after, function(item) {
            $(item).insertAfter(dragMultiple.items.elm);
        });

        _.forEach(before, function(item) {
            $(item).insertBefore(dragMultiple.items.elm);
        });
    };


    var isMultiple = function(elm, container) {
        var items = $(container).find('.' + multipleSortableClass);

        if (!$(elm).hasClass(multipleSortableClass) || !(items.length > 1)) {
            return false;
        }

        return true;
    };

    var setIndex = function(items) {
        var before = [];
        var after = [];
        var mainFound = false;
        _.forEach(items, function(item, index) {
            if ($(item).data('dragMultipleIndex') === 0) {
                mainFound = true;
                return;
            }

            if (mainFound) {
                after.push(item);
            } else {
                before.push(item);
            }
        });

        before.reverse();

        _.forEach(after, function(item, index)  {
            $(item).data('dragMultipleIndex', index + 1);
        });

        _.forEach(before, function(item, index)  {
            $(item).data('dragMultipleIndex', -index - 1);
        });
    };

    var dragMultiple = {};

    dragMultiple.prepare = function(elm, container) {
        inProgress = true;

        var items = $(container).find('.' + multipleSortableClass);

        _.forEach(items, function(item, index) {
            $(item)
                .data('position', null)
                .data('dragMultipleIndex', null);
        });

        $(elm)
            .data('dragmultiple:originalPosition', $(elm).position())
            .data('dragMultipleActive', true);

        dragMultiple.items = {};

        dragMultiple.items.elm = $(elm);
        dragMultiple.items.container = $(container);

        dragMultiple.items.elm.data('dragMultipleIndex', 0);

        setIndex(items);

        dragMultiple.items.shadow = $('.gu-mirror');

        dragMultiple.items.elm.addClass(mainClass);

        items = _.filter(items, function(item) {
            return !$(item).hasClass(mainClass);
        });

        dragMultiple.items.draggedItemsOriginal = items;

        var itemsCloned = _.map(items, function (item) {
            clone = $(item).clone(true);

            clone
                .addClass('multiple-drag-mirror')
                .addClass('tg-multiple-drag-mirror')
                .data('dragmultiple:originalPosition', $(item).position())
                .data('dragMultipleActive', true)
                .css({
                    zIndex: '9999',
                    opacity: '0.8',
                    position: 'fixed',
                    width: dragMultiple.items.elm.outerWidth(),
                    height: $(item).outerHeight()
                });

            $(item)
                .hide()
                .addClass('tg-multiple-drag-dragging');

            return clone;
        });

        dragMultiple.items.draggingItems = itemsCloned;

        $(document.body).append(itemsCloned);
    };

    dragMultiple.start = function(item, container) {
        if (isMultiple(item, container)) {
            document.documentElement.addEventListener('mousemove', function() {
                if (!inProgress) {
                    dragMultiple.prepare(item, container);
                }

                drag();

                removeEventFn = arguments.callee;
            });
        }
    };

    dragMultiple.stop = function() {
        if (inProgress) {
            return stop();
        } else {
            return [];
        }
    };

    dragMultiple.getElements = function() {
        return $('.' + multipleSortableClass);
    };

    window.dragMultiple = dragMultiple;
}());
