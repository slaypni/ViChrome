this.vichrome ?= {}
g = this.vichrome

$.fn.extend {
    isWithinScreen : (padding=10)->
        offset = $(@).offset()
        unless offset? then return false

        if offset.left + padding > window.pageXOffset + window.innerWidth or \
           offset.left - padding < window.pageXOffset
            return false

        if offset.top + padding > window.pageYOffset + window.innerHeight or \
           offset.top - padding < window.pageYOffset
            return false

        return true

    scrollTo : (x, y, speed=80) ->
        offset = $($(@).get(0)).offset()
        unless x? or y?
            unless offset? then return $(@)
            if $(@).isWithinScreen() then return $(@)

        newX = offset.left - window.innerWidth / 2
        newY = offset.top - window.innerHeight / 2

        if newX > document.body.scrollLeft - window.innerWidth
            newX - document.body.scrollLeft - window.innerWidth

        if newY > document.body.scrollHeight - window.innerHeight
            newX = document.body.scrollHeight - window.innerHeight

        left = x ? newX
        top  = y ? newY

        unless g.model.getSetting "smoothScroll"
            speed = 0

        $(document.body).animate( {scrollTop : top, scrollLeft : left}, speed )
        return $(@)

    scrollBy : (x=0, y=0, speed=35) ->
        top  = window.pageYOffset  + y
        left = window.pageXOffset  + x

        unless g.model.getSetting "smoothScroll"
            speed = 0

        $(document.body).animate( {scrollTop : top, scrollLeft : left}, speed )
        return $(@)
}

$.extend( $.expr[':'],
    scrollable : (elem) ->
        overflow = $.curCSS(elem, 'overflow')
        switch overflow
            when "auto","scroll" then return true

        false
)

class g.Surface
    init : ->
        align = g.model.getSetting "commandBoxAlign"

        @statusLine = $( '<div id="vichromestatusline" />' )
                      .addClass( 'vichrome-statuslineinactive' )
                      .addClass( "vichrome-statusline" + align )
                      .width( g.model.getSetting "commandBoxWidth" )
        @statusLineActivated = false

        if top?
            path = chrome.extension.getURL("commandbox.html");
            @iframe = $("<iframe src=\"#{path}\" id=\"vichrome-commandframe\" seamless />")
            @attach( @iframe )
            @iframe.hide()


        $(document.body).click( (e)=>
            @scrollee = $(e.target).closest(":scrollable").get(0)
            @scrollee ?= window
        )
        @initialized = true

    attach : (w) ->
        if top?
            $('html').append(w)
        this

    activateStatusLine : (isVisible = true) ->
        if @slTimeout
            clearTimeout( @slTimeout )
            @slTimeout = undefined

        if not @statusLineActivated
            @statusLine.removeClass( 'vichrome-statuslineinactive' )
            @attach( @statusLine )
        if isVisible
            @statusLine.show()
        else
            @statusLine.hide()
        @statusLineActivated = true

        this

    inactiveStatusLine : ->
        @statusLine.addClass( 'vichrome-statuslineinactive' )
        return this

    hideStatusLine : ->
        unless top?
            chrome.extension.sendRequest( {
                command      : "TopFrame"
                innerCommand : "HideStatusLine"
            })
            return

        if @slTimeout?
            clearTimeout( @slTimeout )
            @slTimeout = undefined
            
        @statusLine?.detach()
        @statusLineActivated = false
        
        this

    setStatusLineText : (text, timeout, isVisible = true) ->
        unless top?
            chrome.extension.sendRequest( {
                command      : "TopFrame"
                innerCommand : "SetStatusLine"
                text         : text
                timeout      : timeout
            })
            return

        @activateStatusLine(isVisible)
        @statusLine.html( text )

        if timeout
            @slTimeout = setTimeout ( => @statusLine.html("").hide() ), timeout

        this

    detach : (w) -> w.detach()

    focusInput : (idx) ->
        unless @initialized then return this

        $('form input:visible[type=text],form input:visible[type=password],textarea:visible')
        .eq(idx).scrollTo?().focus()
        this

    scrollBy : (x, y) ->
        unless @initialized then return this

        $(document.body).scrollBy(x, y, 20)
        this

    scrollHalfPage : (a) ->
        unless @initialized then return this
        block = window.innerHeight / 2
        @scrollBy( block * a.hor, block * a.ver )
        this


    scrollTo : (x, y) ->
        unless @initialized then return this

        $(document.body).scrollTo(x, y, 80)
        this

    backHist : ->
        unless @initialized then return this

        window.history.back()
        this

    forwardHist : ->
        unless @initialized then return this
        window.history.forward()
        this

    reload : ->
        unless @initialized then return this

        window.location.reload()
        this
    open : (url, a)->
        unless @initialized then return this
        window.open(url, a)
        this
    goTop : ->
        unless @initialized then return this
        @scrollTo( window.pageXOffset, 0 )
        this

    goBottom : ->
        unless @initialized then return this
        @scrollTo( window.pageXOffset, document.body.scrollHeight - window.innerHeight )
        this

    getHref : ->
        window.location.href

    blurActiveElement : ->
        unless @initialized then return this

        document.activeElement?.blur()
        this
    hideCommandFrame : ->
        unless top?
            chrome.extension.sendRequest( {
                command      : "TopFrame"
                innerCommand : "HideCommandFrame"
            })
            return
        @iframe.hide()

    showCommandFrame : ->
        @iframe?.show()
