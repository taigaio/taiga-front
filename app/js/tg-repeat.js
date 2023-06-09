/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright (c) 2021-present Kaleidos Ventures SL
 */

/*
  --replace
  minError -> angular.$$minErr
  isString -> angular.isString
  isArray -> angular.isArray
  var expression = $attr.ngRepeat; ->  var expression = $attr.tgRepeat;
  forEach(nextBlockOrder, function(block) { -> nextBlockOrder.forEach(function(block) {
  $scope.$watchCollection(rhs, function ngRepeatAction(collection) {
  ->
  $scope.$watch(rhs, function ngRepeatAction(immutable_collection) {
      var collection = []

      if (immutable_collection.toJS) {
          collection = immutable_collection.toJS();
      }
  $scope[aliasAs] = collection; -> $scope[aliasAs] = immutable_collection;

value = collection[key];
immutable_value = immutable_collection.get(key); #x2

trackById = trackByIdFn(key, value, index);
->
trackById = trackByIdFn(key, immutable_value, index);

updateScope(block.scope, index, valueIdentifier, value, keyIdentifier, key, collectionLength);
-> (x2)
updateScope(block.scope, index, valueIdentifier, immutable_value, keyIdentifier, key, collectionLength);

  --copy from angular
  copy angular hashKey
  copy angular createMap
  copy angular isArrayLike
  copy angular isWindow
  copy angular NODE_TYPE_ELEMENT
  copy angular nextUid
  copy angular getBlockNodes
  --add
  jqLite = $
  var uid = 0;
*/

(function() {
    var NODE_TYPE_ELEMENT = 1;
    var uid = 0;

    function nextUid() {
        return ++uid;
    }

    function hashKey(obj, nextUidFn) {
        var key = obj && obj.$$hashKey;

        if (key) {
            if (typeof key === 'function') {
                key = obj.$$hashKey();
            }
            return key;
        }

        var objType = typeof obj;
        if (objType == 'function' || (objType == 'object' && obj !== null)) {
            key = obj.$$hashKey = objType + ':' + (nextUidFn || nextUid)();
        } else {
            key = objType + ':' + obj;
        }

        return key;
    }

    function createMap() {
        return Object.create(null);
    }

    function isArrayLike(obj) {
        if (obj == null || isWindow(obj)) {
            return false;
        }

        var length = obj.length;

        if (obj.nodeType === NODE_TYPE_ELEMENT && length) {
            return true;
        }

        return angular.isString(obj) || angular.isArray(obj) || length === 0 ||
            typeof length === 'number' && length > 0 && (length - 1) in obj;
    }

    function isWindow(obj) {
        return obj && obj.window === obj;
    }

    function isString(value) {return typeof value === 'string';}

    function getBlockNodes(nodes) {
        // TODO(perf): just check if all items in `nodes` are siblings and if they are return the original
        //             collection, otherwise update the original collection.
        var node = nodes[0];
        var endNode = nodes[nodes.length - 1];
        var blockNodes = [node];

        do {
            node = node.nextSibling;
            if (!node) break;
            blockNodes.push(node);
        } while (node !== endNode);

        return jqLite(blockNodes);
    }

    var jqLite = $;

    var ngRepeatDirective = ['$parse', '$animate', function($parse, $animate) {
        var NG_REMOVED = '$$NG_REMOVED';
        var ngRepeatMinErr = angular.$$minErr('ngRepeat');
        var updateScope = function(scope, index, valueIdentifier, value, keyIdentifier, key, arrayLength) {
            // TODO(perf): generate setters to shave off ~40ms or 1-1.5%
            scope[valueIdentifier] = value;
            if (keyIdentifier) scope[keyIdentifier] = key;
            scope.$index = index;
            scope.$first = (index === 0);
            scope.$last = (index === (arrayLength - 1));
            scope.$middle = !(scope.$first || scope.$last);
            // jshint bitwise: false
            scope.$odd = !(scope.$even = (index&1) === 0);
            // jshint bitwise: true
        };
        var getBlockStart = function(block) {
            return block.clone[0];
        };
        var getBlockEnd = function(block) {
            return block.clone[block.clone.length - 1];
        };
        return {
            restrict: 'A',
            multiElement: true,
            transclude: 'element',
            priority: 1000,
            terminal: true,
            $$tlb: true,
            compile: function ngRepeatCompile($element, $attr) {
                var expression = $attr.tgRepeat;
                var ngRepeatEndComment = document.createComment(' end ngRepeat: ' + expression + ' ');
                var match = expression.match(/^\s*([\s\S]+?)\s+in\s+([\s\S]+?)(?:\s+as\s+([\s\S]+?))?(?:\s+track\s+by\s+([\s\S]+?))?\s*$/);
                if (!match) {
                    throw ngRepeatMinErr('iexp', "Expected expression in form of '_item_ in _collection_[ track by _id_]' but got '{0}'.",
                                         expression);
                }
                var lhs = match[1];
                var rhs = match[2];
                var aliasAs = match[3];
                var trackByExp = match[4];

                match = lhs.match(/^(?:(\s*[\$\w]+)|\(\s*([\$\w]+)\s*,\s*([\$\w]+)\s*\))$/);
                if (!match) {
                    throw ngRepeatMinErr('iidexp', "'_item_' in '_item_ in _collection_' should be an identifier or '(_key_, _value_)' expression, but got '{0}'.",
                                         lhs);
                }
                var valueIdentifier = match[3] || match[1];
                var keyIdentifier = match[2];
                if (aliasAs && (!/^[$a-zA-Z_][$a-zA-Z0-9_]*$/.test(aliasAs) ||
                                /^(null|undefined|this|\$index|\$first|\$middle|\$last|\$even|\$odd|\$parent|\$root|\$id)$/.test(aliasAs))) {
                    throw ngRepeatMinErr('badident', "alias '{0}' is invalid --- must be a valid JS identifier which is not a reserved name.",
                                         aliasAs);
                }
                var trackByExpGetter, trackByIdExpFn, trackByIdArrayFn, trackByIdObjFn;
                var hashFnLocals = {$id: hashKey};
                if (trackByExp) {
                    trackByExpGetter = $parse(trackByExp);
                } else {
                    trackByIdArrayFn = function(key, value) {
                        return hashKey(value);
                    };
                    trackByIdObjFn = function(key) {
                        return key;
                    };
                }
                return function ngRepeatLink($scope, $element, $attr, ctrl, $transclude) {
                    if (trackByExpGetter) {
                        trackByIdExpFn = function(key, value, index) {
                            // assign key, value, and $index to the locals so that they can be used in hash functions
                            if (keyIdentifier) hashFnLocals[keyIdentifier] = key;
                            hashFnLocals[valueIdentifier] = value;
                            hashFnLocals.$index = index;
                            return trackByExpGetter($scope, hashFnLocals);
                        };
                    }
                    // Store a list of elements from previous run. This is a hash where key is the item from the
                    // iterator, and the value is objects with following properties.
                    // - scope: bound scope
                    // - element: previous element.
                    // - index: position
                    //
                    // We are using no-proto object so that we don't need to guard against inherited props via
                    // hasOwnProperty.
                    var lastBlockMap = createMap();
                    $scope.$watch(rhs, function ngRepeatAction(immutable_collection) {
                        var collection = []

                        if (immutable_collection && immutable_collection.toJS) {
                            collection = immutable_collection.toJS();
                        }

                        var index, length,
                        previousNode = $element[0], // node that cloned nodes should be inserted after
                        // initialized to the comment node anchor
                        nextNode,
                        // Same as lastBlockMap but it has the current state. It will become the
                        // lastBlockMap on the next iteration.
                        nextBlockMap = createMap(),
                        collectionLength,
                        key, value, // key/value of iteration
                        trackById,
                        trackByIdFn,
                        collectionKeys,
                        block, // last object information {scope, element, id}
                        nextBlockOrder,
                        elementsToRemove;
                        if (aliasAs) {
                            $scope[aliasAs] = immutable_collection;
                        }
                        if (isArrayLike(collection)) {
                            collectionKeys = collection;
                            trackByIdFn = trackByIdExpFn || trackByIdArrayFn;
                        } else {
                            trackByIdFn = trackByIdExpFn || trackByIdObjFn;
                            // if object, extract keys, in enumeration order, unsorted
                            collectionKeys = [];
                            for (var itemKey in collection) {
                                if (collection.hasOwnProperty(itemKey) && itemKey.charAt(0) !== '$') {
                                    collectionKeys.push(itemKey);
                                }
                            }
                        }
                        collectionLength = collectionKeys.length;
                        nextBlockOrder = new Array(collectionLength);
                        // locate existing items
                        for (index = 0; index < collectionLength; index++) {
                            key = (collection === collectionKeys) ? index : collectionKeys[index];
                            value = collection[key];
                            immutable_value = immutable_collection.get(key);
                            trackById = trackByIdFn(key, immutable_value, index);
                            if (lastBlockMap[trackById]) {
                                // found previously seen block
                                block = lastBlockMap[trackById];
                                delete lastBlockMap[trackById];
                                nextBlockMap[trackById] = block;
                                nextBlockOrder[index] = block;
                            } else if (nextBlockMap[trackById]) {
                                // if collision detected. restore lastBlockMap and throw an error
                                nextBlockOrder.forEach(function(block) {
                                    if (block && block.scope) lastBlockMap[block.id] = block;
                                });
                                throw ngRepeatMinErr('dupes',
                                                     "Duplicates in a repeater are not allowed. Use 'track by' expression to specify unique keys. Repeater: {0}, Duplicate key: {1}, Duplicate value: {2}",
                                                     expression, trackById, value);
                            } else {
                                // new never before seen block
                                nextBlockOrder[index] = {id: trackById, scope: undefined, clone: undefined};
                                nextBlockMap[trackById] = true;
                            }
                        }
                        // remove leftover items
                        for (var blockKey in lastBlockMap) {
                            block = lastBlockMap[blockKey];
                            elementsToRemove = getBlockNodes(block.clone);
                            $animate.leave(elementsToRemove);
                            if (elementsToRemove[0].parentNode) {
                                // if the element was not removed yet because of pending animation, mark it as deleted
                                // so that we can ignore it later
                                for (index = 0, length = elementsToRemove.length; index < length; index++) {
                                    elementsToRemove[index][NG_REMOVED] = true;
                                }
                            }
                            block.scope.$destroy();
                        }
                        // we are not using forEach for perf reasons (trying to avoid #call)
                        for (index = 0; index < collectionLength; index++) {
                            key = (collection === collectionKeys) ? index : collectionKeys[index];
                            value = collection[key];
                            immutable_value = immutable_collection.get(key);
                            block = nextBlockOrder[index];
                            if (block.scope) {
                                // if we have already seen this object, then we need to reuse the
                                // associated scope/element
                                nextNode = previousNode;
                                // skip nodes that are already pending removal via leave animation
                                do {
                                    nextNode = nextNode.nextSibling;
                                } while (nextNode && nextNode[NG_REMOVED]);
                                if (getBlockStart(block) != nextNode) {
                                    // existing item which got moved
                                    $animate.move(getBlockNodes(block.clone), null, jqLite(previousNode));
                                }
                                previousNode = getBlockEnd(block);
                                updateScope(block.scope, index, valueIdentifier, immutable_value, keyIdentifier, key, collectionLength);
                            } else {
                                // new item which we don't know about
                                $transclude(function ngRepeatTransclude(clone, scope) {
                                    block.scope = scope;
                                    // http://jsperf.com/clone-vs-createcomment
                                    var endNode = ngRepeatEndComment.cloneNode(false);
                                    clone[clone.length++] = endNode;
                                    // TODO(perf): support naked previousNode in `enter` to avoid creation of jqLite wrapper?
                                    $animate.enter(clone, null, jqLite(previousNode));
                                    previousNode = endNode;
                                    // Note: We only need the first/last node of the cloned nodes.
                                    // However, we need to keep the reference to the jqlite wrapper as it might be changed later
                                    // by a directive with templateUrl when its template arrives.
                                    block.clone = clone;
                                    nextBlockMap[block.id] = block;
                                    updateScope(block.scope, index, valueIdentifier, immutable_value, keyIdentifier, key, collectionLength);
                                });
                            }
                        }
                        lastBlockMap = nextBlockMap;
                    });
                };
            }
        };
    }];

    angular.module("tgRepeat", []).directive("tgRepeat", ngRepeatDirective);
})();
