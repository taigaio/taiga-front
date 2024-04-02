###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

angular.module("taigaCommon").provider("$exceptionHandler", angular.mock.$ExceptionHandlerProvider)

describe "AppMetaService", ->
    appMetaService = null
    $rootScope = null
    data = {
        title: "--title--",
        description: "--description--"
    }

    _inject = () ->
        inject (_tgAppMetaService_, _$rootScope_) ->
            appMetaService = _tgAppMetaService_
            $rootScope = _$rootScope_

    before ->
        window._version = 1

    beforeEach ->
        module "taigaCommon"
        _inject()

    it "set meta title", () ->
        appMetaService.setTitle(data.title)
        expect($("title")).to.have.text(data.title)

    it "set meta description", () ->
        appMetaService.setDescription(data.description)
        expect($("meta[name='description']")).to.have.attr("content", data.description)

    it "set meta for twitter", () ->
        appMetaService.setTwitterMetas(data.title, data.description)
        expect($("meta[name='twitter:card']")).to.have.attr("content",  "summary")
        expect($("meta[name='twitter:site']")).to.have.attr("content",  "@taigaio")
        expect($("meta[name='twitter:title']")).to.have.attr("content",  data.title)
        expect($("meta[name='twitter:description']")).to.have.attr("content",  data.description)
        expect($("meta[name='twitter:image']")).to.have.attr("content",  "#{window.location.origin}/#{window._version}/images/logo-color.png")

    it "set meta for open graph", () ->
        appMetaService.setOpenGraphMetas(data.title, data.description)
        expect($("meta[property='og:type']")).to.have.attr("content", "object")
        expect($("meta[property='og:site_name']")).to.have.attr("content", "Taiga - Love your projects")
        expect($("meta[property='og:title']")).to.have.attr("content", data.title)
        expect($("meta[property='og:description']")).to.have.attr("content", data.description)
        expect($("meta[property='og:image']")).to.have.attr("content", "#{window.location.origin}/#{window._version}/images/logo-color.png")
        expect($("meta[property='og:url']")).to.have.attr("content", window.location.href)

    it "set all meta", () ->
        appMetaService.setAll(data.title, data.description)
        expect($("title")).to.have.text(data.title)
        expect($("meta[name='description']")).to.have.attr("content", data.description)
        expect($("meta[name='twitter:card']")).to.have.attr("content",  "summary")
        expect($("meta[name='twitter:site']")).to.have.attr("content",  "@taigaio")
        expect($("meta[name='twitter:title']")).to.have.attr("content",  data.title)
        expect($("meta[name='twitter:description']")).to.have.attr("content",  data.description)
        expect($("meta[name='twitter:image']")).to.have.attr("content",  "#{window.location.origin}/#{window._version}/images/logo-color.png")
        expect($("meta[property='og:type']")).to.have.attr("content", "object")
        expect($("meta[property='og:site_name']")).to.have.attr("content", "Taiga - Love your projects")
        expect($("meta[property='og:title']")).to.have.attr("content", data.title)
        expect($("meta[property='og:description']")).to.have.attr("content", data.description)
        expect($("meta[property='og:image']")).to.have.attr("content", "#{window.location.origin}/#{window._version}/images/logo-color.png")
        expect($("meta[property='og:url']")).to.have.attr("content", window.location.href)

    it "set function to set the metas", () ->
        fn = () ->
            return {
                title: 'test',
                description: 'test2'
            }


        appMetaService.setAll = sinon.stub()
        appMetaService.setfn(fn)

        $rootScope.$digest()

        expect(appMetaService.setAll).to.have.been.calledWith('test', 'test2')
