# [Template](http://neocotic.com/template)  
# (c) 2012 Alasdair Mercer  
# Freely distributable under the MIT license.  
# For all details and documentation:  
# <http://neocotic.com/template>

# Private variables
# -----------------

# Easily accessible reference to analytics, logging, utilities, and the
# extension controller.
{analytics, ext, log, utils} = chrome.extension.getBackgroundPage()

# Popup page setup
# ----------------

popup = window.popup = new class Popup extends utils.Class

  # Public functions
  # ----------------

  # Initialize the popup page.
  init: ->
    log.trace()
    log.info 'Initializing the popup'
    analytics.track 'Frames', 'Displayed', 'Popup'
    # Insert the prepared HTML in to the popup's body and bind click events.
    document.getElementById('templates').innerHTML = ext.templatesHtml
    items = document.querySelectorAll '#templates li > a'
    item.addEventListener 'click', popup.sendRequest for item in items
    # Calculate the widest text used by the elements in the popup and assign it
    # to all of the others.
    for item in items when not width? or item.scrollWidth > width
      width = item.scrollWidth
    item.style.width = "#{width}px" for item in items
    log.debug "Widest textual item in popup is #{width}px"
    width = document.querySelector('#templates li').scrollWidth
    document.getElementById('loading').style.width = "#{width + 2}px"

  # Send a request to the background page using the information provided.
  sendRequest: ->
    log.trace()
    request =
      data: key: @getAttribute 'data-key'
      type: @getAttribute 'data-type'
    log.debug 'Sending the following request to the extension controller',
      request
    chrome.extension.sendRequest request

# Initialize `popup` when the DOM is ready.
utils.ready this, -> popup.init()