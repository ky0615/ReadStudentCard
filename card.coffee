pafe = require "libpafe"
pasori = new pafe.Pasori()

http = require "http"

wpi = require "wiring-pi"

pin = 1
wpi.setup "wpi"
wpi.pinMode pin, wpi.OUTPUT

wpi.softToneCreate pin

class Card
    idmCache = "a"

    readCard: =>
        # console.log "start read card"
        pasori.setTimeout 100
        pasori.polling 0xFE00, 0, (felica)=>
            unless felica
                # console.log "felica is not found"
                @readCard()
                return
            idm = felica.getIDm()
            setTimeout @readCard, 1500
            if idm is idmCache
                # console.log "Same card"
                return
            console.log idm
            idmCache = idmCache
            setTimeout deleteIdmCache, 3000
            @readData felica
            return

    deleteIdmCache = ->
        idmCache = ""

    readData: (felica)=>
        try
            num = felica.readSingle 0x1A8B, 0, 0x0000
                .map (s)-> String.fromCharCode s
                .slice 2, 9
                .join ""

            name = felica.readSingle 0x1A8B, 0, 0x0001
                .filter (s)-> s isnt 0
                .map (s)-> String.fromCharCode s
                .join ""
            @sendCardData
                number: num
                name: name
        catch e
            console.log e

    sendCardData: (card)=>
        post_data = JSON.stringify card
        console.log post_data
        post_req = http.request
            host: "kokoiru.linux.moe"
            port: "443"
            path: "/attend"
            method: 'POST'
            headers:
                'Content-Type': 'application/json'
                'Content-Length': Buffer.byteLength(post_data)
                "Authorization": "Basic dGR1ZmU6dGR1ZmU="
        , (res)=>
            res.setEncoding "utf8"
            res.on "data", (chunk)=>
                console.log chunk
                data = JSON.parse chunk
                console.log data
                unless data.leftFlag
                    # now
                    @toneSingle 250
                else
                    # left
                    @toneDouble()

        post_req.write post_data
        post_req.end()

    toneStart: ->
        wpi.softToneWrite pin, 349*4
    toneStop: ->
        wpi.softToneWrite pin, 0
    toneSingle: (ms)->
        @toneStart()
        setTimeout @toneStop, ms
    toneDouble: ->
        @toneStart()
        setTimeout @toneStop, 100
        setTimeout @toneStart, 200
        setTimeout @toneStop, 450

card = new Card()

card.readCard()
