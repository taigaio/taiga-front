###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

isValidObsidianUrl = (url) ->
    return false unless url.hostname is "open"
    return false if url.username or url.password or url.port or url.pathname or url.href.indexOf("#") != -1

    keys = []
    url.searchParams.forEach (value, key) -> keys.push(key)
    return false unless keys.length is 2 and url.searchParams.get("vault") and url.searchParams.get("file")
    return keys.every (key) -> key in ["vault", "file"]

isValidCustomFieldUrl = (value) ->
    return false unless _.isString(value) and value.length
    # URL parsing strips control characters; reject them before checking the scheme.
    return false if /[\x00-\x20\x7f]/.test(value)

    try
        url = new URL(value, window.location.href)
    catch
        return false

    if url.protocol is "obsidian:"
        return isValidObsidianUrl(url)

    return false unless url.protocol in ["http:", "https:", "ftp:", "sftp:", "git:", "mailto:"]
    return validators.type(value, "url")

validators = checksley.updateValidators({customfieldurl: isValidCustomFieldUrl})
@.taiga.isValidCustomFieldUrl = isValidCustomFieldUrl
