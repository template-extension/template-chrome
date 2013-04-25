# [Template](http://neocotic.com/template)  
# (c) 2013 Alasdair Mercer  
# Freely distributable under the MIT license.  
# For all details and documentation:  
# <http://neocotic.com/template>

# Extending prototypes
# --------------------

# Transform the string into title case.
String::capitalize = ->
  @replace /\w+/g, (word) ->
    word.charAt(0).toUpperCase() + word.substr(1).toLowerCase()

# Private constants
# -----------------

# List of blacklisted extension IDs that should be prevented from sending
# external messages to Template.
BLACKLIST         = []
# Predefined templates to be used by default.
DEFAULT_TEMPLATES = [
    content:  '{url}'
    enabled:  yes
    image:    'globe'
    index:    0
    key:      'PREDEFINED.00001'
    readOnly: yes
    shortcut: 'U'
    title:    i18n.get 'default_template_url'
    usage:    0
  ,
    content:  '{#shorten}{url}{/shorten}'
    enabled:  yes
    image:    'tag'
    index:    1
    key:      'PREDEFINED.00002'
    readOnly: yes
    shortcut: 'S'
    title:    i18n.get 'default_template_short'
    usage:    0
  ,
    content:  "<a href=\"{url}\"{#anchorTarget}
 target=\"_blank\"{/anchorTarget}{#anchorTitle}
 title=\"{{title}}\"{/anchorTitle}>{{title}}</a>"
    enabled:  yes
    image:    'font'
    index:    2
    key:      'PREDEFINED.00003'
    readOnly: yes
    shortcut: 'A'
    title:    i18n.get 'default_template_anchor'
    usage:    0
  ,
    content:  '{#encode}{url}{/encode}'
    enabled:  yes
    image:    'lock'
    index:    3
    key:      'PREDEFINED.00004'
    readOnly: yes
    shortcut: 'E'
    title:    i18n.get 'default_template_encoded'
    usage:    0
  ,
    content:  '[url={url}]{title}[/url]'
    enabled:  no
    image:    'comment'
    index:    5
    key:      'PREDEFINED.00005'
    readOnly: yes
    shortcut: 'B'
    title:    i18n.get 'default_template_bbcode'
    usage:    0
  ,
    content:  '[{title}]({url})'
    enabled:  no
    image:    'asterisk'
    index:    4
    key:      'PREDEFINED.00006'
    readOnly: yes
    shortcut: 'M'
    title:    i18n.get 'default_template_markdown'
    usage:    0
  ,
    content:  '{selectionMarkdown}'
    enabled:  no
    image:    'italic'
    index:    6
    key:      'PREDEFINED.00007'
    readOnly: yes
    shortcut: 'I'
    title:    i18n.get 'default_template_markdown_selection'
    usage:    0
]
# Extension ID being used by Template.
EXTENSION_ID      = i18n.get '@@extension_id'
# Domain of this extension's homepage.
HOMEPAGE_DOMAIN   = 'neocotic.com'
# List of known operating systems that could be used by the user.
OPERATING_SYSTEMS = [
  substring: 'Win'
  title:     'Windows'
,
  substring: 'Mac'
  title:     'Mac'
,
  substring: 'Linux'
  title:     'Linux'
]
# Milliseconds before the popup automatically resets or closes, depending on
# user preferences.
POPUP_DELAY       = 600
# Regular expression used to extract useful information from `select` tag name
# variations.
R_SELECT_TAG      = /^select(all)?(\S*)?$/
# Regular expression used to detect upper case characters.
R_UPPER_CASE      = /[A-Z]+/
# Regular expression used to perform simple URL validation.
R_VALID_URL       = /^https?:\/\/\S+\.\S+/i
# Extension ID of the production version of Template.
REAL_EXTENSION_ID = 'dcjnfaoifoefmnbhhlbppaebgnccfddf'
# List of URL shortener services supported by Template.
SHORTENERS        = [
  # Setup [bitly](http://bit.ly).
  getHeaders:    -> 'Content-Type': 'application/x-www-form-urlencoded'
  getParameters: (url) ->
    params =
      format:  'json'
      longUrl: url
    if @oauth.hasAccessToken()
      params.access_token = @oauth.getAccessToken()
    else
      params.apiKey = ext.config.services.bitly.api_key
      params.login  = ext.config.services.bitly.login
    params
  getUsage:      -> store.get 'bitly.usage'
  input:         -> null
  isEnabled:     -> store.get 'bitly.enabled'
  method:        'GET'
  name:          'bitly'
  oauth:         -> new OAuth2 'bitly',
    client_id:     ext.config.services.bitly.client_id
    client_secret: ext.config.services.bitly.client_secret
  output:        (resp) -> JSON.parse(resp).data.url
  title:         i18n.get 'shortener_bitly'
  url:           -> ext.config.services.bitly.url
,
  # Setup [Google URL Shortener](http://goo.gl).
  getHeaders:    ->
    headers = 'Content-Type': 'application/json'
    if @oauth.hasAccessToken()
      headers.Authorization = "OAuth #{@oauth.getAccessToken()}"
    headers
  getParameters: -> unless @oauth.hasAccessToken()
    key: ext.config.services.googl.api_key
  getUsage:      -> store.get 'googl.usage'
  input:         (url) -> JSON.stringify longUrl: url
  isEnabled:     -> store.get 'googl.enabled'
  method:        'POST'
  name:          'googl'
  oauth:         -> new OAuth2 'google',
    api_scope:     ext.config.services.googl.api_scope
    client_id:     ext.config.services.googl.client_id
    client_secret: ext.config.services.googl.client_secret
  output:        (resp) -> JSON.parse(resp).id
  title:         i18n.get 'shortener_googl'
  url:           -> ext.config.services.googl.url
,
  # Setup [YOURLS](http://yourls.org).
  getHeaders:    -> 'Content-Type': 'application/json'
  getParameters: (url) ->
    params =
      action: 'shorturl'
      format: 'json'
      url:    url
    yourls = store.get 'yourls'
    switch yourls.authentication
      when 'advanced'
        params.signature = yourls.signature if yourls.signature
      when 'basic'
        params.password = yourls.password if yourls.password
        params.username = yourls.username if yourls.username
    params
  getUsage:      -> store.get 'yourls.usage'
  input:         -> null
  isEnabled:     -> store.get 'yourls.enabled'
  method:        'POST'
  name:          'yourls'
  output:        (resp) -> JSON.parse(resp).shorturl
  title:         i18n.get 'shortener_yourls'
  url:           -> store.get 'yourls.url'
]
# List of extensions supported by Template and used for compatibility purposes.
SUPPORT           =
  # Setup [IE Tab](http://ietab.net).
  hehijbfgiekmjfkfjpbkbammjbdenadd: (tab) ->
    if tab.title
      str = 'IE: '
      idx = tab.title.indexOf str
      tab.title = tab.title.substring idx + str.length if idx isnt -1
    if tab.url
      str = 'iecontainer.html#url='
      idx = tab.url.indexOf str
      if idx isnt -1
        tab.url = decodeURIComponent tab.url.substring idx + str.length
  # Setup [IE Tab Classic](http://goo.gl/u7Cau).
  miedgcmlgpmdagojnnbemlkgidepfjfi: (tab) ->
    if tab.url
      str = 'ie.html#'
      idx = tab.url.indexOf str
      tab.url = tab.url.substring idx + str.length if idx isnt -1
  # Setup [IE Tab Multi (Enhance)](http://iblogbox.com/chrome/ietab).
  fnfnbeppfinmnjnjhedifcfllpcfgeea: (tab) ->
    if tab.url
      str = 'navigate.html?chromeurl='
      idx = tab.url.indexOf str
      if idx isnt -1
        tab.url = tab.url.substring idx + str.length
        str = '[escape]'
        if tab.url.indexOf(str) is 0
          tab.url = decodeURIComponent tab.url.substring str.length
  # Setup [Mozilla Gecko Tab](http://iblogbox.com/chrome/geckotab).
  icoloanbecehinobmflpeglknkplbfbm: (tab) ->
    if tab.url
      str = 'navigate.html?chromeurl='
      idx = tab.url.indexOf str
      if idx isnt -1
        tab.url = tab.url.substring idx + str.length
        str = '[escape]'
        if tab.url.indexOf(str) is 0
          tab.url = decodeURIComponent tab.url.substring str.length

# Private variables
# -----------------

# Details of the current browser.
browser           =
  title:   'Chrome'
  version: ''
# Indicate whether or not Template has just been installed.
isNewInstall      = no
# Indicate whether or not Template is currently running the production build.
isProductionBuild = EXTENSION_ID is REAL_EXTENSION_ID
# Name of the user's operating system.
operatingSystem   = ''

# Private functions
# -----------------

# Inject and execute the `content.coffee` and `install.coffee` scripts within
# all of the tabs (where valid) of each Chrome window.
executeScriptsInExistingWindows = ->
  log.trace()
  chrome.tabs.query {}, (tabs) ->
    log.info 'Retrieved the following tabs...', tabs
    # Check tabs are not displaying a *protected* page (i.e. one that will
    # cause an error if an attempt is made to execute content scripts).
    for tab in tabs when not isProtectedPage tab
      chrome.tabs.executeScript tab.id, file: 'lib/content.js'
      # Only execute inline installation content script for tabs displaying a
      # page on Template's homepage domain.
      if HOMEPAGE_DOMAIN in tab.url
        chrome.tabs.executeScript tab.id, file: 'lib/install.js'

# Attempt to derive the current version of the user's browser.
getBrowserVersion = ->
  log.trace()
  str = navigator.userAgent
  idx = str.indexOf browser.title
  if idx isnt -1
    str = str.substring idx + browser.title.length + 1
    idx = str.indexOf ' '
    if idx is -1 then str else str.substring 0, idx

# Build list of shortcuts used by enabled templates.
getHotkeys = ->
  log.trace()
  template.shortcut for template in ext.templates when template.enabled

# Derive the operating system being used by the user.
getOperatingSystem = ->
  log.trace()
  str = navigator.platform
  for os in OPERATING_SYSTEMS when str.indexOf(os.substring) isnt -1
    str = os.title
    break
  str

# Attempt to retrieve the template with the specified `key`.
getTemplateWithKey = (key) ->
  log.trace()
  ext.queryTemplate (template) -> template.key is key

# Attempt to retrieve the template with the specified `menuId`.
getTemplateWithMenuId = (menuId) ->
  log.trace()
  ext.queryTemplate (template) -> template.menuId is menuId

# Attempt to retrieve the template with the specified keyboard `shortcut`.  
# Exclude disabled templates from this query.
getTemplateWithShortcut = (shortcut) ->
  log.trace()
  ext.queryTemplate (template) ->
    template.enabled and template.shortcut is shortcut

# Determine whether or not the specified extension is blacklisted.
isBlacklisted = (extensionId) ->
  log.trace()
  return yes for extension in BLACKLIST when extension is extensionId
  no

# Determine whether or not the specified extension is active on `tab`.
isExtensionActive = (tab, extensionId) ->
  log.trace()
  log.debug "Checking activity of #{extensionId}"
  isSpecialPage(tab) and extensionId in tab.url

# Determine whether or not `tab` is currently displaying a page on the Chrome
# Extension Gallery (i.e. Web Store).
isExtensionGallery = (tab) ->
  log.trace()
  tab.url.indexOf('https://chrome.google.com/webstore') is 0

# Determine whether or not `tab` is currently displaying a *protected* page
# (i.e. a page that content scripts cannot be executed on).
isProtectedPage = (tab) ->
  log.trace()
  isSpecialPage(tab) or isExtensionGallery tab

# Determine whether or not `tab` is currently displaying a *special* page (i.e.
# a page that is internal to the browser).
isSpecialPage = (tab) ->
  log.trace()
  not tab.url.indexOf 'chrome'

# Ensure `null` is returned instead of `object` if it is *empty*.
nullIfEmpty = (object) ->
  log.trace()
  if $.isEmptyObject object then null else object

# Listener for internal messages sent to the extension.  
# External messages are also routed through here, but only after being checked
# that they do not originate from a blacklisted extension.
onMessage = (message, sender, sendResponse) ->
  log.trace()
  # Safely handle callback functionality.
  callback = utils.callback sendResponse
  # Message type is required. Informal rejection.
  return callback() unless message.type
  # Don't allow shortcut requests when shortcuts are disabled.
  if message.type is 'shortcut' and not store.get 'shortcuts.enabled'
    return callback()
  # Select or create a tab for the Options page.
  if message.type is 'options'
    selectOrCreateTab utils.url 'pages/options.html'
    # Close the popup if it's currently open. This should happen naturally but
    # is being forced to ensure consistency.
    chrome.extension.getViews(type: 'popup')[0]?.close()
    return callback()
  # Info requests are simple, just send some useful information back. Done!
  if message.type in ['info', 'version']
    return callback
      hotkeys: getHotkeys()
      id:      EXTENSION_ID
      version: ext.version
  active       = data   = output   = template = null
  editable     = link   = shortcut = no
  id           = utils.keyGen '', null, 't', no
  placeholders = {}
  async.series [
    (done) ->
      chrome.tabs.query active: yes, currentWindow: yes, (tabs) ->
        log.debug 'Retrieved the following tabs...', tabs
        active = _.first tabs
        done()
    (done) ->
      # Return a callback function to be used by a tag to indicate that it
      # requires further action.  
      # Replace the tag with the unique placeholder so that it can be rendered
      # again later with the final value.
      getCallback = (tag) ->
        (text, render) ->
          text = render text if text
          text = @url if tag is 'shorten' and not text
          trim = text.trim()
          log.debug "Following is the contents of a #{tag} tag...", text
          # If `trim` doesn't appear to be a valid so just return the rendered
          # `text`.
          if not trim or tag is 'shorten' and not R_VALID_URL.test trim
            return text
          for own key, val of placeholders
            if val.data is trim and val.tag is tag
              placeholder = key
              break
          unless placeholder?
            placeholder = utils.keyGen '', null, 'c', no
            placeholders[placeholder] =
              data: trim
              tag:  tag
            # Sections are re-rendered so the context must have a property for
            # the placeholder the replaces itself with itself so that it still
            # when it comes to replacing with the final value.
            this[placeholder] = "{#{placeholder}}"
          log.debug "Replacing #{tag} tag with #{placeholder} placeholder"
          "{#{placeholder}}"
      # If the popup is currently displayed, hide the template list and show a
      # loading animation.
      updateProgress null, on
      # Attempt to derive the contextual template data.
      try
        template                         = deriveMessageTempate message
        updateProgress 10
        {data, editable, link, shortcut} = deriveMessageInfo message, active,
          getCallback
        updateProgress 20
        done()
      catch err
        log.error err
        # Oops! Something went wrong so we should probably let the user know.
        if err instanceof AppError
          done err
        else
          msg = if err instanceof URIError
            'result_bad_uri_description'
          else
            'result_bad_error_description'
          done new AppError msg
    (done) ->
      # Extract additional data from the environment.
      addAdditionalData active, data, id, editable, shortcut, link, ->
        updateProgress 40
        # Ensure all properties of `data` are lower case.
        transformData data
        # To complete the data, simply extend it using `template`.
        $.extend data, {template}
        log.debug "Using the following data to render #{template.title}...",
          data
        if template.content
          output = Mustache.render template.content, data
          log.debug 'Following string is the rendered result...', output
          updateProgress 60
        output ?= ''
        done()
    (done) ->
      updateProgress 80
      # Only proceed if any placeholders were inserted and replaced, as they
      # need to be handled now in order to replace any placeholders with their
      # final values.
      return done() if _.isEmpty placeholders
      selectMap  = {}
      shortenMap = {}
      for own placeholder, info of placeholders
        if info.tag is 'shorten'
          shortenMap[placeholder] = info.data
        else
          match = info.tag.match R_SELECT_TAG
          selectMap[placeholder] =
            all:       match[1]?
            convertTo: match[2]
            selector:  info.data
      async.series [
        (done) ->
          return done() if _.isEmpty selectMap
          runSelectors active, selectMap, ->
            log.info 'One or more selectors were executed'
            updateProgress 85
            for own placeholder, value of selectMap
              placeholders[placeholder] = value
            done()
        (done) ->
          return done() if _.isEmpty shortenMap
          callUrlShortener shortenMap, (err, response) ->
            log.info 'URL shortener service was called one or more times'
            updateProgress 90
            unless err
              updateUrlShortenerUsage response.service.name, response.oauth
              for own placeholder, value of shortenMap
                placeholders[placeholder] = value
            done err
      ], (err) ->
        unless err
          # Request(s) were successful so re-render the output.
          output = Mustache.render output, placeholders
          log.debug 'Following string is the re-rendered result...', output
        done err
  ], (err) ->
    type  = message.type[0].toUpperCase() + message.type.substr 1
    value = message.data.key.charCodeAt 0 if shortcut
    analytics.track 'Requests', 'Processed', type, value
    updateProgress 100
    # Ensure that the user is notified if they have attempted to copy an empty
    # string to the system clipboard.
    if not err and not output
      err = new Error i18n.get 'result_bad_empty_description', template.title
    if err
      log.warn err.message
      ext.notification.title       = i18n.get 'result_bad_title'
      ext.notification.titleStyle  = 'color: #B94A48'
      ext.notification.description = err.message ?
        i18n.get 'result_bad_description', template.title
      showNotification()
    else
      updateTemplateUsage template.key
      updateStatistics()
      ext.notification.title       = i18n.get 'result_good_title'
      ext.notification.titleStyle  = 'color: #468847'
      ext.notification.description = i18n.get 'result_good_description',
        template.title
      ext.copy output
      if not isProtectedPage(active) and
         (editable and store.get 'menu.paste') or
         (shortcut and store.get 'shortcuts.paste')
        chrome.tabs.sendMessage active.id,
          {contents: output, id, type: 'paste'}
    log.debug "Finished handling #{type} request"

# Listener for external messages sent to the extension.  
# Only messages sent from extensions/apps that have not been previously
# blacklisted routed to `onMessage`.
onMessageExternal = (message, sender, sendResponse) ->
  log.trace()
  # Safely handle callback functionality.
  callback = utils.callback sendResponse
  # Ensure blacklisted extensions/apps are blocked.
  blocked  = isBlacklisted sender.id
  analytics.track 'External Requests', 'Started', sender.id, Number !blocked
  if blocked
    log.debug "Blocking external request from #{sender.id}"
    return callback()
  log.debug "Accepting external request from #{sender.id}"
  onMessage message, sender, sendResponse

# Attempt to select a tab in the current window displaying a page whose
# location begins with `url`.  
# If no existing tab exists a new one is simply created.
selectOrCreateTab = (url, callback) ->
  log.trace()
  chrome.windows.getLastFocused populate: yes, (win) ->
    log.debug 'Retrieved the following window...', win
    log.debug 'Retrieved the following tabs...',   win.tabs
    # Try to find an existing tab that begins with `url`.
    for tab in win.tabs when not tab.url.indexOf url
      existing = tab
      break
    if existing?
      # Found one! Now to select it.
      chrome.tabs.update existing.id, active: yes
      callback? existing
    else
      # Ach well, let's just create a new one.
      chrome.tabs.create {windowId: win.id, url, active: yes}, (tab) ->
        callback? tab

# Display a desktop notification informing the user on whether or not the copy
# request was successful.  
# Also, ensure that `ext` is *reset* and that notifications are only displayed
# if the user has enabled the corresponding option (enabled by default).
showNotification = ->
  log.trace()
  if store.get 'notifications.enabled'
    webkitNotifications.createHTMLNotification(
      utils.url 'pages/notification.html'
    ).show()
  else
    ext.reset()
  updateProgress null, off

# Update hotkeys stored by the `content.coffee` script within all of the tabs
# (where valid) of each Chrome window.
updateHotkeys = ->
  log.trace()
  hotkeys = getHotkeys()
  chrome.tabs.query {}, (tabs) ->
    log.info 'Retrieved the following tabs...', tabs
    # Check tabs are not displaying a *protected* page (i.e. one that will
    # cause an error if an attempt is made to send a message to it).
    for tab in tabs when not isProtectedPage tab
      chrome.tabs.sendMessage tab.id, {hotkeys}

# Update the popup UI state to reflect the progress of the current request.  
# Ignore `percent` if `toggle` is specified; otherwise update the percentage on
# the progress bar and reset the delay timer.  
# `toggle` can be used to show the progress bar or reset/close the popup.
updateProgress = (percent, toggle) ->
  log.trace()
  popup       = $ chrome.extension.getViews(type: 'popup')[0]
  templates   = if popup.length then $ '#templates', popup[0].document else $()
  loading     = if popup.length then $ '#loading',   popup[0].document else $()
  progressBar = loading.find '.bar'
  # Update the progress bar to display the specified `percent`.
  if toggle?
    if toggle
      progressBar.css 'width', '0%'
      popup.delay            POPUP_DELAY
      templates.hide().delay POPUP_DELAY
      loading.show().delay   POPUP_DELAY
    else
      if store.get 'toolbar.close'
        popup.queue -> popup.dequeue()[0]?.close()
      else
        loading.queue ->
          loading.hide().dequeue()
          progressBar.css 'width', '0%'
        templates.queue -> templates.show().dequeue()
  else if percent?
    popup.dequeue().delay     POPUP_DELAY
    templates.dequeue().delay POPUP_DELAY
    loading.dequeue().delay   POPUP_DELAY
    progressBar.css 'width', "#{percent}%"

# Update the statistical information.
updateStatistics = ->
  log.trace()
  log.info 'Updating statistics'
  store.init 'stats', {}
  store.modify 'stats', (stats) =>
    # Determine which template has the greatest usage.
    maxUsage = 0
    utils.query ext.templates, no, (template) ->
      maxUsage = template.usage if template.usage > maxUsage
      no
    popular = ext.queryTemplate (template) -> template.usage is maxUsage
    # Calculate the up-to-date statistical information.
    stats.count       = ext.templates.length
    stats.customCount = stats.count - DEFAULT_TEMPLATES.length
    stats.popular     = popular?.key

# Increment the usage for the template with the specified `key` and persist the
# changes.
updateTemplateUsage = (key) ->
  log.trace()
  for template in ext.templates when template.key is key
    template.usage++
    break
  store.set 'templates', ext.templates
  log.info "Used #{template.title} template"
  analytics.track 'Templates', 'Used', template.title, Number template.readOnly

# Increment the usage for the URL shortener service with the specified `name`
# and persist the changes.
updateUrlShortenerUsage = (name, oauth) ->
  log.trace()
  store.modify name, (shortener) -> shortener.usage++
  shortener = ext.queryUrlShortener (shortener) -> shortener.name is name
  log.info "Used #{shortener.title} URL shortener"
  analytics.track 'Shorteners', 'Used', shortener.title, Number oauth

# Errors
# ------

# `AppError` allows easy identification of internal errors.
class AppError extends Error

  # Create a new instance of `AppError` with a localized message.
  constructor: (messageKey, substitutions...) ->
    if messageKey
      @message = i18n.get messageKey, substitutions

# Data functions
# --------------

# Extract additional information from `tab` and add it to `data`.
addAdditionalData = (tab, data, id, editable, shortcut, link, callback) ->
  log.trace()
  chrome.windows.get tab.windowId, populate: yes, (win) ->
    log.info 'Retrieved the following window...', win
    log.info 'Retrieved the following tabs...',   win.tabs
    $.extend data, tabs: (winTab.url for winTab in win.tabs)
    async.parallel [
      (done) ->
        coords = {}
        navigator.geolocation.getCurrentPosition (position) ->
          log.debug 'Retrieved the following geolocation information...',
            position
          for own prop, value of position.coords
            coords[prop.toLowerCase()] = if value? then "#{value}" else ''
          done null, {coords}
        , (err) ->
          log.warn err.message
          done null, {coords}
      (done) ->
        chrome.cookies.getAll url: data.url, (cookies = []) ->
          log.debug 'Retrieved the following cookies...', cookies
          done null,
            cookie: ->
              (text, render) ->
                # Attempt to find the value for the cookie name.
                name = render text
                for cookie in cookies when cookie.name is name
                  result = cookie.value
                  break
                result ? ''
            cookies: (
              names = []
              for cookie in cookies when cookie.name not in names
                names.push cookie.name
              names
            )
      (done) ->
        # Try to prevent pages hanging because content script should not have
        # been executed.
        return done() if isProtectedPage tab
        chrome.tabs.sendMessage tab.id,
          {editable, id, link, shortcut, url: data.url}
        , (response) ->
          log.debug 'Retrieved the following data from content script...',
            response
          lastModified = if response.lastModified?
            time = Date.parse response.lastModified
            new Date time unless isNaN time
          done null,
            author:         response.author         ? ''
            characterset:   response.characterSet   ? ''
            description:    response.description    ? ''
            images:         response.images         ? []
            keywords:       response.keywords       ? []
            lastmodified:   -> (text, render) ->
              lastModified?.format(render(text) or undefined) ? ''
            linkhtml:       response.linkHTML       ? ''
            links:          response.links          ? []
            linktext:       response.linkText       ? ''
            pageheight:     response.pageHeight     ? ''
            pagewidth:      response.pageWidth      ? ''
            referrer:       response.referrer       ? ''
            scripts:        response.scripts        ? []
            selectedimages: response.selectedImages ? []
            selectedlinks:  response.selectedLinks  ? []
            selection:      response.selection      ? ''
            selectionhtml:  response.selectionHTML  ? ''
            # Deprecated since 1.0.0, use `selectedLinks` instead.
            selectionlinks: -> @selectedlinks
            stylesheets:    response.styleSheets    ? []
    ], (err, results = []) ->
      log.error err if err
      $.extend data, result for result in results when result?
      callback()

# Creates an object containing data based on information derived from the
# specified tab and menu item data.
buildDerivedData = (tab, onClickData, getCallback) ->
  log.trace()
  obj  = editable: onClickData.editable, link: no
  data =
    title: tab.title
    url:   if onClickData.linkUrl
        obj.link = yes
        onClickData.linkUrl
      else if onClickData.srcUrl
        onClickData.srcUrl
      else if onClickData.frameUrl
        onClickData.frameUrl
      else
        onClickData.pageUrl
  obj.data = buildStandardData data, getCallback
  obj

# Construct a data object based on information extracted from `tab`.  
# The tab information is then merged with additional information relating to
# the URL of the tab.  
# If a tag requires further action (e.g. call a URL shortening service) when
# parsing the templates contents later, the callback method returned by
# `getCallback` is called to handle this as we don't want to perform these
# expensive tasks unless it is actually required.
buildStandardData = (tab, getCallback) ->
  log.trace()
  # Create a copy of the original tab of the tab to run the compatibility
  # scripts on.
  ctab = {}
  $.extend ctab, tab
  # Check for any support extensions running on the current tab by simply
  # checking the tabs URL.
  for own extension, handler of SUPPORT when isExtensionActive tab, extension
    log.debug "Making data compatible with #{extension}"
    handler? ctab
    break
  # Build the initial URL data.
  data = {}
  url  = $.url ctab.url
  # Create references to the base of all grouped options to improve lookup
  # performance.
  anchor        = store.get 'anchor'
  bitly         = store.get 'bitly'
  googl         = store.get 'googl'
  menu          = store.get 'menu'
  notifications = store.get 'notifications'
  shortcuts     = store.get 'shortcuts'
  stats         = store.get 'stats'
  toolbar       = store.get 'toolbar'
  yourls        = store.get 'yourls'
  # Merge the initial data with the attributes of the [URL
  # parser](https://github.com/allmarkedup/jQuery-URL-Parser) and all of the
  # custom Template properties.  
  # All properties should be in lower case so that they can be looked up
  # ignoring case by our modified version of
  # [mustache.js](https://github.com/janl/mustache.js).
  $.extend data, url.attr(),
    anchortarget:          anchor.target
    anchortitle:           anchor.title
    bitly:                 bitly.enabled
    bitlyaccount:          ->
      ext.queryUrlShortener((shortener) ->
        shortener.name is 'bitly'
      ).oauth.hasAccessToken()
    browser:               browser.title
    browserversion:        browser.version
    capitalise:            -> @capitalize()
    capitalize:            -> (text, render) ->
      render(text).capitalize()
    # Deprecated since 1.0.0, use `menu` instead.
    contextmenu:           -> @menu
    cookiesenabled:        navigator.cookieEnabled
    count:                 stats.count
    customcount:           stats.customCount
    datetime:              -> (text, render) ->
      new Date().format(render(text) or undefined) ? ''
    decode:                -> (text, render) ->
      decodeURIComponent(render text) ? ''
    depth:                 screen.colorDepth
    # Deprecated since 1.0.0, use `anchortarget` instead.
    doanchortarget:        -> @anchortarget
    # Deprecated since 1.0.0, use `anchortitle` instead.
    doanchortitle:         -> @anchortitle
    encode:                -> (text, render) ->
      encodeURIComponent(render text) ? ''
    # Deprecated since 0.1.0.2, use `encode` instead.
    encoded:               -> encodeURIComponent @url
    escape:                -> (text, render) ->
      _.escape render text
    favicon:               ctab.favIconUrl
    fparam:                -> (text, render) ->
      url.fparam(render text) ? ''
    fparams:               nullIfEmpty url.fparam()
    fsegment:              -> (text, render) ->
      url.fsegment(parseInt render(text), 10) ? ''
    fsegments:             url.fsegment()
    googl:                 googl.enabled
    googlaccount:          ->
      ext.queryUrlShortener((shortener) ->
        shortener.name is 'googl'
      ).oauth.hasAccessToken()
    # Deprecated since 1.0.0, use `googlaccount` instead.
    googloauth:            -> @googlaccount()
    java:                  navigator.javaEnabled()
    length:                -> (text, render) ->
      render(text).length
    linkmarkdown:          -> md @linkhtml
    lowercase:             -> (text, render) ->
      render(text).toLowerCase()
    menu:                  menu.enabled
    menuoptions:           menu.options
    menupaste:             menu.paste
    notifications:         notifications.enabled
    notificationduration:  notifications.duration * .001
    offline:               not navigator.onLine
    # Deprecated since 0.1.0.2, use `originalurl` instead.
    originalsource:        -> @originalurl
    originaltitle:         tab.title or url.attr 'source'
    originalurl:           tab.url
    os:                    operatingSystem
    param:                 -> (text, render) ->
      url.param(render text) ? ''
    params:                nullIfEmpty url.param()
    plugins:               (
      results = []
      for plugin in navigator.plugins when plugin.name not in results
        results.push plugin.name
      results.sort()
    )
    popular:               ext.queryTemplate (template) ->
      template.key is stats.popular
    screenheight:          screen.height
    screenwidth:           screen.width
    segment:               -> (text, render) ->
      url.segment(parseInt render(text), 10) ? ''
    segments:              url.segment()
    select:                -> getCallback 'select'
    selectall:             -> getCallback 'selectall'
    selectallhtml:         -> getCallback 'selectallhtml'
    selectallmarkdown:     -> getCallback 'selectallmarkdown'
    selecthtml:            -> getCallback 'selecthtml'
    selectionmarkdown:     -> md @selectionhtml
    selectmarkdown:        -> getCallback 'selectmarkdown'
    # Deprecated since 1.0.0, use `shorten` instead.
    short:                 -> @shorten()
    shortcuts:             shortcuts.enabled
    shortcutspaste:        shortcuts.paste
    shorten:               -> getCallback 'shorten'
    tidy:                  -> (text, render) ->
      render(text).replace(/([ \t]+)/g, ' ').trim()
    title:                 ctab.title or url.attr 'source'
    toolbarclose:          toolbar.close
    # Deprecated since 1.0.0, use the inverse of `toolbarpopup` instead.
    toolbarfeature:        -> not @toolbarpopup
    # Deprecated since 1.0.0, use `toolbarstyle` instead.
    toolbarfeaturedetails: -> @toolbarstyle
    # Deprecated since 1.0.0, use `toolbarkey` instead.
    toolbarfeaturename:    -> @toolbarkey
    toolbarkey:            toolbar.key
    toolbaroptions:        toolbar.options
    toolbarpopup:          toolbar.popup
    # Obsolete since 1.1.0, functionality has been removed.
    toolbarstyle:          no
    trim:                  -> (text, render) ->
      render(text).trim()
    trimleft:              -> (text, render) ->
      render(text).trimLeft()
    trimright:             -> (text, render) ->
      render(text).trimRight()
    unescape:              -> (text, render) ->
      _.unescape render text
    uppercase:             -> (text, render) ->
      render(text).toUpperCase()
    url:                   url.attr 'source'
    version:               ext.version
    yourls:                yourls.enabled
    yourlsauthentication:  yourls.authentication
    yourlspassword:        yourls.password
    yourlssignature:       yourls.signature
    yourlsurl:             yourls.url
    yourlsusername:        yourls.username
  data

# Derive the relevant information, including the template data, based on both
# `message` and `tab`.
deriveMessageInfo = (message, tab, getCallback) ->
  log.trace()
  info =
    data:     null
    editable: no
    link:     no
    shortcut: no
  $.extend info, switch message.type
    when 'menu'
      buildDerivedData tab, message.data, getCallback
    when 'popup', 'toolbar'
      data: buildStandardData tab, getCallback
    when 'shortcut'
      data:     buildStandardData tab, getCallback
      shortcut: yes
    else
      throw new AppError 'result_bad_type_description'
  info

# Derive the relevant template based on the context of `message`.
deriveMessageTempate = (message) ->
  log.trace()
  template = switch message.type
    when 'menu'
      getTemplateWithMenuId message.data.menuItemId
    when 'popup', 'toolbar'
      getTemplateWithKey message.data.key
    when 'shortcut'
      getTemplateWithShortcut message.data.key
    else
      throw new AppError 'result_bad_type_description'
  throw new AppError 'result_bad_template_description' unless template?
  template

# Run the selectors in `map` within the content scripts in `tab` in order to
# obtain their corresponding values.  
# `callback` will be called with the result once all the selectors have been
# run.
runSelectors = (tab, map, callback) ->
  log.trace()
  if isProtectedPage tab
    map[placeholder] = '' for own placeholder of map
    callback()
  else
    chrome.tabs.sendMessage tab.id, selectors: map, (response) ->
      log.debug 'Retrieved the following data from the content script...',
        response
      for own placeholder, value of response.selectors
        result = value.result or ''
        result = result.join '\n' if $.isArray result
        result = md result if value.convertTo is 'markdown'
        map[placeholder] = result
      callback()

# Ensure there is a lower case variant of all properties of `data`, optionally
# removing the original non-lower-case property.
transformData = (data, deleteOld) ->
  log.trace()
  for own prop, value of data when R_UPPER_CASE.test prop
    data[prop.toLowerCase()] = value
    delete data[prop] if deleteOld

# HTML building functions
# -----------------------

# Build the HTML to populate the popup with to optimize popup loading times.
buildPopup = ->
  log.trace()
  items = $()
  # Generate the HTML for each template.
  for template in ext.templates when template.enabled
    items = items.add buildTemplate template
  # Add a generic message to state the obvious... that the list is empty.
  if items.length is 0
    items = items.add $('<li/>',
      class: 'empty'
    ).append($ '<i/>',
      class: 'icon-'
    ).append " #{i18n.get 'empty'}"
  # Add a link to the options page if the user doesn't mind.
  if store.get 'toolbar.options'
    items = items.add $ '<li/>', class: 'divider'
    anchor = $ '<a/>',
      class:       'options'
      'data-type': 'options'
    anchor.append $ '<i/>', class: icons.getClass 'cog'
    anchor.append " #{i18n.get 'options'}"
    items = items.add $('<li/>').append anchor
  ext.templatesHtml = $('<div/>').append(items).html()

# Create an `li` element to represent `template`.  
# The element should then be inserted in to the `ul` element in the popup page
# but is created here to optimize display times for the popup.
buildTemplate = (template) ->
  log.trace()
  log.debug "Creating popup list item for #{template.title}"
  anchor = $ '<a/>',
    'data-key':  template.key
    'data-type': 'popup'
  if template.shortcut and store.get 'shortcuts.enabled'
    if ext.isThisPlatform 'mac'
      modifiers = ext.SHORTCUT_MAC_MODIFIERS
    else
      modifiers = ext.SHORTCUT_MODIFIERS
    anchor.append $ '<span/>',
      class: 'pull-right',
      html:  "#{modifiers}#{template.shortcut}"
  anchor.append $ '<i/>', class: icons.getClass template.image
  anchor.append " #{template.title}"
  $('<li/>').append anchor

# Initialization functions
# ------------------------

# Handle the conversion/removal of older version of settings that may have been
# stored previously by `ext.init`.
init_update = ->
  log.trace()
  # Update the update progress indicator itself.
  if store.exists 'update_progress'
    store.modify 'updates', (updates) ->
      progress = store.remove 'update_progress'
      for own namespace, versions of progress
        updates[namespace] = if versions?.length then versions.pop() else ''
  # Create updater for the `settings` namespace.
  updater      = new store.Updater 'settings'
  isNewInstall = updater.isNew
  # Define the processes for all required updates to the `settings`
  # namespace.
  updater.update '0.1.0.0', ->
    log.info 'Updating general settings for 0.1.0.0'
    store.rename 'settingNotification',      'notifications',        on
    store.rename 'settingNotificationTimer', 'notificationDuration', 3000
    store.rename 'settingShortcut',          'shortcuts',            on
    store.rename 'settingTargetAttr',        'doAnchorTarget',       off
    store.rename 'settingTitleAttr',         'doAnchorTitle',        off
    store.remove 'settingIeTabExtract',      'settingIeTabTitle'
  updater.update '1.0.0', ->
    log.info 'Updating general settings for 1.0.0'
    if store.exists 'options_active_tab'
      optionsActiveTab = store.get 'options_active_tab'
      store.set 'options_active_tab', switch optionsActiveTab
        when 'features_nav' then 'templates_nav'
        when 'toolbar_nav' then 'general_nav'
        else optionsActiveTab
    store.modify 'anchor', (anchor) ->
      anchor.target = store.get('doAnchorTarget') ? off
      anchor.title  = store.get('doAnchorTitle') ? off
    store.remove 'doAnchorTarget', 'doAnchorTitle'
    store.modify 'menu', (menu) ->
      menu.enabled = store.get('contextMenu') ? yes
    store.remove 'contextMenu'
    store.set 'notifications',
      duration: store.get('notificationDuration') ? 3000
      enabled:  store.get('notifications') ? yes
    store.remove 'notificationDuration'
  updater.update '1.1.0', ->
    log.info 'Updating general settings for 1.1.0'
    store.set 'shortcuts',
      enabled: store.get('shortcuts') ? yes

# Initialize the settings related to statistical information.
initStatistics = ->
  log.trace()
  updateStatistics()

# Initialize `template` and its properties, before adding it to `templates` to
# be persisted later.
initTemplate = (template, templates) ->
  log.trace()
  # Derive the index of `template` to determine whether or not it already
  # exists.
  idx = templates.indexOf utils.query templates, yes, (tmpl) ->
    tmpl.key is template.key
  if idx is -1
    # `template` doesn't already exist so add it now.
    log.debug 'Adding the following predefined template...', template
    templates.push template
  else
    # `template` exists so modify the properties to ensure they are reliable.
    log.debug 'Ensuring following template adheres to structure...', template
    if template.readOnly
      # `template` is read-only so certain properties should always be
      # overriden and others only when they are not already available.
      templates[idx].content   = template.content
      templates[idx].enabled  ?= template.enabled
      templates[idx].image    ?= template.image
      templates[idx].index    ?= template.index
      templates[idx].key       = template.key
      templates[idx].readOnly  = yes
      templates[idx].shortcut ?= template.shortcut
      templates[idx].title     = template.title
      templates[idx].usage    ?= template.usage
    else
      # `template` is *not* read-only so set unavailable, but required,
      # properties to their default value.
      templates[idx].content  ?= ''
      templates[idx].enabled  ?= yes
      templates[idx].image    ?= ''
      templates[idx].index    ?= 0
      templates[idx].key      ?= template.key
      templates[idx].readOnly  = no
      templates[idx].shortcut ?= ''
      templates[idx].title    ?= '?'
      templates[idx].usage    ?= 0
    template = templates[idx]
  template

# Initialize the persisted managed templates.
initTemplates = ->
  log.trace()
  initTemplates_update()
  store.modify 'templates', (templates) ->
    # Initialize all default templates to ensure their properties are as
    # expected.
    initTemplate template, templates for template in DEFAULT_TEMPLATES
    # Now, initialize *all* templates to ensure their properties are valid.
    initTemplate template, templates for template in templates
  ext.updateTemplates()

# Handle the conversion/removal of older version of settings that may have been
# stored previously by `initTemplates`.
initTemplates_update = ->
  log.trace()
  # Create updater for the `features` namespace and then rename it to
  # `templates`.
  updater = new store.Updater 'features'
  updater.rename 'templates'
  # Define the processes for all required updates to the `templates` namespace.
  updater.update '0.1.0.0', ->
    log.info 'Updating template settings for 0.1.0.0'
    store.rename 'copyAnchorEnabled',  'feat__anchor_enabled',  yes
    store.rename 'copyAnchorOrder',    'feat__anchor_index',    2
    store.rename 'copyBBCodeEnabled',  'feat__bbcode_enabled',  no
    store.rename 'copyBBCodeOrder',    'feat__bbcode_index',    4
    store.rename 'copyEncodedEnabled', 'feat__encoded_enabled', yes
    store.rename 'copyEncodedOrder',   'feat__encoded_index',   3
    store.rename 'copyShortEnabled',   'feat__short_enabled',   yes
    store.rename 'copyShortOrder',     'feat__short_index',     1
    store.rename 'copyUrlEnabled',     'feat__url_enabled',     yes
    store.rename 'copyUrlOrder',       'feat__url_index',       0
  updater.update '0.2.0.0', ->
    log.info 'Updating template settings for 0.2.0.0'
    names = store.get('features') ? []
    for name in names when typeof name is 'string'
      store.rename "feat_#{name}_template", "feat_#{name}_content"
      image = store.get "feat_#{name}_image"
      if typeof image is 'string'
        if image in ['', 'spacer.gif', 'spacer.png']
          store.set "feat_#{name}_image", 0
        else
          for legacy, i in icons.LEGACY
            oldImg = legacy.image.replace /^tmpl/, 'feat'
            if "#{oldImg}.png" is image
              store.set "feat_#{name}_image", i + 1
              break
      else
        store.set "feat_#{name}_image", 0
  updater.update '1.0.0', ->
    log.info 'Updating template settings for 1.0.0'
    names              = store.remove('features') ? []
    templates          = []
    toolbarFeatureName = store.get 'toolbarFeatureName'
    for name in names when typeof name is 'string'
      image = store.remove("feat_#{name}_image") ? 0
      image--
      image = if image >= 0
        icons.fromLegacy(image)?.name or ''
      else
        ''
      key = ext.getKeyForName name
      if toolbarFeatureName is name
        if store.exists 'toolbar'
          store.modify 'toolbar', (toolbar) -> toolbar.key = key
        else
          store.set 'toolbar', key: key
      templates.push
        content:  store.remove("feat_#{name}_content")  ? ''
        enabled:  store.remove("feat_#{name}_enabled")  ? yes
        image:    image
        index:    store.remove("feat_#{name}_index")    ? 0
        key:      key
        readOnly: store.remove("feat_#{name}_readonly") ? no
        shortcut: store.remove("feat_#{name}_shortcut") ? ''
        title:    store.remove("feat_#{name}_title")    ? '?'
        usage:    0
    store.set 'templates', templates
    store.remove store.search(
      /^feat_.*_(content|enabled|image|index|readonly|shortcut|title)$/
    )...
  updater.update '1.1.0', ->
    log.info 'Updating template settings for 1.1.0'
    store.modify 'templates', (templates) ->
      for template in templates
        if template.readOnly
          break for base in DEFAULT_TEMPLATES when base.key is template.key
          switch template.key
            when 'PREDEFINED.00001'
              template.image = if template.image is 'tmpl_globe'
                base.image
              else
                icons.fromLegacy(template.image)?.name or ''
            when 'PREDEFINED.00002'
              template.image = if template.image is 'tmpl_link'
                base.image
              else
                icons.fromLegacy(template.image)?.name or ''
            when 'PREDEFINED.00003'
              template.image = if template.image is 'tmpl_html'
                base.image
              else
                icons.fromLegacy(template.image)?.name or ''
            when 'PREDEFINED.00004'
              template.image = if template.image is 'tmpl_component'
                base.image
              else
                icons.fromLegacy(template.image)?.name or ''
            when 'PREDEFINED.00005'
              template.image = if template.image is 'tmpl_discussion'
                base.image
              else
                icons.fromLegacy(template.image)?.name or ''
            when 'PREDEFINED.00006'
              template.image = if template.image is 'tmpl_discussion'
                base.image
              else
                icons.fromLegacy(template.image)?.name or ''
            when 'PREDEFINED.00007'
              template.image = if template.image is 'tmpl_note'
                base.image
              else
                icons.fromLegacy(template.image)?.name or ''
            else template.image = base.image
        else
          template.image = icons.fromLegacy(template.image)?.name or ''

# Initialize the settings related to the toolbar/browser action.
initToolbar = ->
  log.trace()
  initToolbar_update()
  store.modify 'toolbar', (toolbar) ->
    toolbar.close   ?= yes
    toolbar.key     ?= 'PREDEFINED.00001'
    toolbar.options ?= yes
    toolbar.popup   ?= yes
  ext.updateToolbar()

# Handle the conversion/removal of older version of settings that may have been
# stored previously by `initToolbar`.
initToolbar_update = ->
  log.trace()
  # Create updater for the `toolbar` namespace.
  updater = new store.Updater 'toolbar'
  # Define the processes for all required updates to the `toolbar` namespace.
  updater.update '1.0.0', ->
    log.info 'Updating toolbar settings for 1.0.0'
    store.modify 'toolbar', (toolbar) ->
      toolbar.popup = store.get('toolbarPopup') ? yes
      toolbar.style = store.get('toolbarFeatureDetails') ? no
    store.remove 'toolbarFeature',     'toolbarFeatureDetails',
                 'toolbarFeatureName', 'toolbarPopup'
  updater.update '1.1.0', ->
    log.info 'Updating toolbar settings for 1.1.0'
    store.modify 'toolbar', (toolbar) -> delete toolbar.style

# Initialize the settings related to the supported URL Shortener services.
initUrlShorteners = ->
  log.trace()
  store.init
    bitly:  {}
    googl:  {}
    yourls: {}
  initUrlShorteners_update()
  store.modify 'bitly', (bitly) ->
    bitly.enabled ?= yes
    bitly.usage   ?= 0
  store.modify 'googl', (googl) ->
    googl.enabled ?= no
    googl.usage   ?= 0
  store.modify 'yourls', (yourls) ->
    yourls.authentication ?= ''
    yourls.enabled        ?= no
    yourls.password       ?= ''
    yourls.signature      ?= ''
    yourls.url            ?= ''
    yourls.username       ?= ''
    yourls.usage          ?= 0

# Handle the conversion/removal of older version of settings that may have been
# stored previously by `initUrlShorteners`.
initUrlShorteners_update = ->
  log.trace()
  # Create updater for the `shorteners` namespace.
  updater = new store.Updater 'shorteners'
  # Define the processes for all required updates to the `shorteners`
  # namespace.
  updater.update '0.1.0.0', ->
    log.info 'Updating URL shortener settings for 0.1.0.0'
    store.rename 'bitlyEnabled',       'bitly',         yes
    store.rename 'bitlyXApiKey',       'bitlyApiKey',   ''
    store.rename 'bitlyXLogin',        'bitlyUsername', ''
    store.rename 'googleEnabled',      'googl',         no
    store.rename 'googleOAuthEnabled', 'googlOAuth',    yes
  updater.update '1.0.0', ->
    log.info 'Updating URL shortener settings for 1.0.0'
    bitly = store.get 'bitly'
    store.set 'bitly',
      apiKey:    store.get('bitlyApiKey') ? ''
      enabled:   if typeof bitly is 'boolean' then bitly else yes
      username:  store.get('bitlyUsername') ? ''
    store.remove 'bitlyApiKey', 'bitlyUsername'
    googl = store.get 'googl'
    store.set 'googl',
      enabled: if typeof googl is 'boolean' then googl else no
    store.remove 'googlOAuth'
    yourls = store.get 'yourls'
    store.set 'yourls',
      enabled:   if typeof yourls is 'boolean' then yourls else no
      password:  store.get('yourlsPassword') ? ''
      signature: store.get('yourlsSignature') ? ''
      url:       store.get('yourlsUrl') ? ''
      username:  store.get('yourlsUsername') ? ''
    store.remove 'yourlsPassword', 'yourlsSignature', 'yourlsUrl',
                 'yourlsUsername'
  updater.update '1.0.1', ->
    store.modify 'bitly', (bitly) ->
      delete bitly.apiKey
      delete bitly.username
    store.modify 'yourls', (yourls) ->
      yourls.authentication = if yourls.signature
        'advanced'
      else if yourls.password and yourls.username
        'basic'
      else 
        ''
    store.remove store.search(/^oauth_token.*/)...

# URL shortener functions
# -----------------------

# Call the active URL shortener service for each URL in `map` in order to
# obtain their corresponding short URLs.  
# `callback` will be called with the result once all URLs have been shortened
# or an error is encountered.
callUrlShortener = (map, callback) ->
  log.trace()
  service  = getActiveUrlShortener()
  endpoint = service.url()
  oauth    = no
  title    = service.title
  # Ensure the service URL exists in case it is user-defined (e.g. YOURLS).
  unless endpoint
    return callback new Error i18n.get 'shortener_config_error', title
  tasks = []
  _.each map, (url, placeholder) ->
    oauth = !!service.oauth?.hasAccessToken()
    tasks.push (done) ->
      async.series [
        (done) ->
          if oauth then service.oauth.authorize -> done()
          else done()
        (done) ->
          params    = service.getParameters url
          endpoint += "?#{$.param params}" if params?
          # Build the HTTP asynchronous request for the URL shortener service.
          xhr = new XMLHttpRequest()
          xhr.open service.method, endpoint, yes
          # Allow service to populate request headers.
          for own header, value of service.getHeaders() ? {}
            xhr.setRequestHeader header, value
          xhr.onreadystatechange = ->
            # Wait for the response and let the service handle it before
            # passing the result back.
            if xhr.readyState is 4
              if xhr.status is 200
                map[placeholder] = service.output xhr.responseText
                done()
              else
                # Something went wrong so let's tell the user.
                message = i18n.get 'shortener_detailed_error', [title, url]
                done new Error message
          # Finally, send the HTTP request.
          xhr.send service.input url
      ], done
  async.series tasks, (err) ->
    if err
      err.message or= i18n.get 'shortener_error', service.title
      callback err
    else
      callback null, {oauth, service}

# Retrieve the active URL shortener service.
getActiveUrlShortener = ->
  log.trace()
  # Attempt to lookup enabled URL shortener service.
  shortener = ext.queryUrlShortener (shortener) -> shortener.isEnabled()
  unless shortener?
    # Should never reach here but we'll return bit.ly service by default after
    # ensuring it's the active URL shortener service from now on to save some
    # time in the future.
    store.modify 'bitly', (bitly) -> bitly.enabled = yes
    shortener = getActiveUrlShortener()
  log.debug "Getting details for #{shortener.title} URL shortener"
  shortener

# Background page setup
# ---------------------

ext = window.ext = new class Extension extends utils.Class

  # Public constants
  # ----------------

  # String representation of the keyboard modifiers listened to by Template on
  # Windows/Linux platforms.
  SHORTCUT_MODIFIERS: 'Ctrl+Alt+'

  # String representation of the keyboard modifiers listened to by Template on
  # Mac platforms.
  SHORTCUT_MAC_MODIFIERS: '&#8679;&#8997;'

  # Public variables
  # ----------------

  # Configuration data loaded at runtime.
  config: {}

  # Information specifying what should be displaying in the notification.  
  # This should be reset after every copy request.
  notification:
    description:      ''
    descriptionStyle: ''
    html:             ''
    icon:             utils.url '../images/icon_48.png'
    iconStyle:        ''
    title:            ''
    titleStyle:       ''

  # Local copy of templates being used, ordered to match that specified by the
  # user.
  templates: []

  # Pre-prepared HTML for the popup to be populated using.  
  # This should be updated whenever templates are changed/updated in any way as
  # this is generated to improve performance and load times of the popup frame.
  templatesHtml: ''

  # Current version of Template.
  version: ''

  # Public functions
  # ----------------

  # Add `str` to the system clipboard.  
  # All successful copy requests should, at some point, call this function.  
  # If `str` is empty the contents of the system clipboard will not change.
  copy: (str, hidden) ->
    log.trace()
    sandbox = $('#sandbox').val(str).select()
    document.execCommand 'copy'
    log.debug 'Copied the following string...', str
    sandbox.val ''
    showNotification() unless hidden

  # Attempt to retrieve the key of the template with the specified `name`.  
  # Since only the names of predefined templates are known, return a newly
  # generated key if it does not match any of their names.
  getKeyForName: (name, generate = yes) ->
    log.trace()
    key = switch name
      when '_url'      then 'PREDEFINED.00001'
      when '_short'    then 'PREDEFINED.00002'
      when '_anchor'   then 'PREDEFINED.00003'
      when '_encoded'  then 'PREDEFINED.00004'
      when '_bbcode'   then 'PREDEFINED.00005'
      when '_markdown' then 'PREDEFINED.00006'
      else utils.keyGen() if generate
    log.debug "Associating #{key} key with #{name} template"
    key

  # Initialize the background page.  
  # This will involve initializing the settings and adding the message
  # listeners.
  init: ->
    log.trace()
    log.info 'Initializing extension controller'
    # Add support for analytics if the user hasn't opted out.
    analytics.add() if store.get 'analytics'
    $.getJSON utils.url('configuration.json'), (data) =>
      # It's nice knowing what version is running.
      {@version} = chrome.runtime.getManifest()
      # Store the configuration data before initiating OAuth for each URL
      # shortener service.
      @config    = data
      shortener.oauth = shortener.oauth?() for shortener in SHORTENERS
      # Begin initialization.
      store.init
        anchor:        {}
        menu:          {}
        notifications: {}
        shortcuts:     {}
        stats:         {}
        templates:     []
        toolbar:       {}
      init_update()
      store.modify 'anchor', (anchor) ->
        anchor.target ?= off
        anchor.title  ?= off
      store.modify 'menu', (menu) ->
        menu.enabled ?= yes
        menu.options ?= yes
        menu.paste   ?= no
      store.modify 'notifications', (notifications) ->
        notifications.duration ?= 3000
        notifications.enabled  ?= yes
      store.modify 'shortcuts', (shortcuts) ->
        shortcuts.enabled ?= yes
        shortcuts.paste   ?= no
      initTemplates()
      initToolbar()
      initStatistics()
      initUrlShorteners()
      # Add listener for toolbar/browser action clicks.  
      # This listener will be ignored whenever the popup is enabled.
      chrome.browserAction.onClicked.addListener (tab) ->
        onMessage
          data: key: store.get 'toolbar.key'
          type: 'toolbar'
      # Add listeners for internal and external messages.
      chrome.runtime.onMessage.addListener onMessage
      chrome.runtime.onMessageExternal.addListener onMessageExternal
      # Derive the browser and OS information.
      browser.version = getBrowserVersion()
      operatingSystem = getOperatingSystem()
      if isNewInstall
        analytics.track 'Installs', 'New', @version, Number isProductionBuild
      # Execute content scripts now that we know the version.
      executeScriptsInExistingWindows()

  # Determine whether or not `os` matches the user's operating system.
  isThisPlatform: (os) ->
    log.trace()
    navigator.userAgent.toLowerCase().indexOf(os) isnt -1

  # Attempt to retrieve the contents of the system clipboard as a string.
  paste: ->
    log.trace()
    result  = ''
    sandbox = $('#sandbox').val('').select()
    result  = sandbox.val() if document.execCommand 'paste'
    log.debug 'Pasted the following string...', result
    sandbox.val ''
    result

  # Retrieve the first template that passes the specified `filter`.
  queryTemplate: (filter, singular = yes) ->
    log.trace()
    utils.query @templates, singular, filter

  # Retrieve all templates that pass the specified `filter`.
  queryTemplates: (filter) -> @queryTemplate filter, no

  # Retrieve the first URL shortener service that passes the specified
  # `filter`.
  queryUrlShortener: (filter, singular = yes) ->
    log.trace()
    utils.query SHORTENERS, singular, filter

  # Retrieve all URL shortener services that pass the specified `filter`.
  queryUrlShorteners: (filter) -> @queryUrlShortener filter, no

  # Reset the notification information associated with the current copy
  # request.  
  # This should be called when a copy request is completed regardless of its
  # outcome.
  reset: ->
    log.trace()
    @notification =
      description:      ''
      descriptionStyle: ''
      html:             ''
      icon:             utils.url '../images/icon_48.png'
      iconStyle:        ''
      title:            ''
      titleStyle:       ''

  # Update the context menu items to reflect the currently enabled templates.  
  # If the context menu option has been disabled by the user, just remove all
  # of the existing menu items.
  updateContextMenu: ->
    log.trace()
    # Ensure that any previously added context menu items are removed.
    chrome.contextMenus.removeAll =>
      # Called whenever a template menu item is clicked.  
      # Message self, passing along the available information.
      onMenuClick = (info, tab) -> onMessage data: info, type: 'menu'
      menu = store.get 'menu'
      if menu.enabled
        # Create and add the top-level Template menu.
        parentId = chrome.contextMenus.create
          contexts: ['all']
          title:    i18n.get 'name'
        # Create and add a sub-menu item for each enabled template.
        for template in @templates when template.enabled
          notEmpty = yes
          menuId   = chrome.contextMenus.create
            contexts: ['all']
            onclick:  onMenuClick
            parentId: parentId
            title:    template.title
          template.menuId = menuId
        unless notEmpty
          chrome.contextMenus.create
            contexts: ['all']
            parentId: parentId
            title:    i18n.get 'empty'
        # Add an item to open the options page if the user doesn't mind.
        if menu.options
          chrome.contextMenus.create
            contexts: ['all']
            parentId: parentId
            type:     'separator'
          chrome.contextMenus.create
            contexts: ['all']
            onclick:  (info, tab) -> onMessage type: 'options'
            parentId: parentId
            title:    i18n.get 'options'

  # Update the local list of templates to reflect those persisted.  
  # It is very important that this is called whenever templates may have been
  # changed in order to prepare the popup HTML and optimize performance.
  updateTemplates: ->
    log.trace()
    @templates = store.get 'templates'
    @templates.sort (a, b) -> a.index - b.index
    buildPopup()
    @updateContextMenu()
    updateStatistics()
    updateHotkeys()

  # Update the toolbar/browser action depending on the current settings.
  updateToolbar: ->
    log.trace()
    key      = store.get 'toolbar.key'
    template = getTemplateWithKey key if key
    buildPopup()
    if not template or store.get 'toolbar.popup'
      log.info 'Configuring toolbar to display popup'
      # Show the popup when the browser action is clicked.
      chrome.browserAction.setPopup popup: 'pages/popup.html'
    else
      log.info 'Configuring toolbar to activate specified template'
      # Disable the popup, effectively enabling the listener for
      # `chrome.browserAction.onClicked`.
      chrome.browserAction.setPopup popup: ''

# Initialize `ext` when the DOM is ready.
utils.ready -> ext.init()