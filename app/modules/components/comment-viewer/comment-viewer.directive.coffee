###
# Copyright (C) 2014-2018 Taiga Agile LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: components/comment-viewer/comment-viewer.directive.coffee
###

CommentViewerDirective = ($wysiwygService) ->
    link = ($scope, $el, $attrs) ->
        $scope.flag = false
        $scope.$watch "content", (content) =>
            $scope.flag = false
            $scope.patched_content = ""
            promise = $wysiwygService.refreshAttachmentURL($scope.content)
            promise.then (html) =>
                $scope.patched_content = html
                $scope.flag = true


    return {
        templateUrl: "components/comment-viewer/comment-viewer.html"
        link: link,
        scope: {
            content: "="
        }
    }

angular.module("taigaComponents").directive("tgCommentViewer", ["tgWysiwygService", CommentViewerDirective])
