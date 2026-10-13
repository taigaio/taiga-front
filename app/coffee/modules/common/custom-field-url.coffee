###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

isValidObsidianUrl = (value) ->
    return false unless /^obsidian:\/\/open\?/i.test(value)
    try
        url = new URL(value)
    catch
        return false

    return false unless url.hostname is "open" and url.searchParams?
    return false if url.username or url.password or url.port or url.pathname or url.href.indexOf("#") != -1

    keys = []
    url.searchParams.forEach (value, key) -> keys.push(key)
    return false unless keys.length is 2 and url.searchParams.get("vault") and url.searchParams.get("file")
    return keys.every (key) -> key in ["vault", "file"]

getCustomFieldUrlHref = (value) ->
    return null unless _.isString(value) and value.length
    # URL parsing strips control characters; reject them before checking the scheme.
    return null if /[\x00-\x20\x7f]/.test(value)

    href = value
    if /^[^:\/?#@]+:\d+(?:[\/?#]|$)/.test(value)
        href = "http://#{value}"

    protocolMatch = /^([a-z][a-z0-9+.-]*):/i.exec(href)
    protocol = protocolMatch[1].toLowerCase() if protocolMatch
    if protocol is "obsidian"
        return href if isValidObsidianUrl(href)
        return null

    return null if protocol? and protocol not in ["http", "https", "ftp", "sftp", "git", "mailto"]
    return null if not protocol? and /^[^\/?#]*:[^\/?#]*@/.test(href)
    return href if validators.type(href, "url")
    return null

isValidCustomFieldUrl = (value) -> getCustomFieldUrlHref(value)?

validators = checksley.updateValidators({customfieldurl: isValidCustomFieldUrl})
@.taiga.isValidCustomFieldUrl = isValidCustomFieldUrl
@.taiga.getCustomFieldUrlHref = getCustomFieldUrlHref
