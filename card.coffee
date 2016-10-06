pafe = require "libpafe"
pasori = new pafe.Pasori()

http = require "http"

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

    sendCardData: (card)->
        post_data = JSON.stringify card
        console.log post_data
        post_req = http.request
            host: "nizuki.cloudapp.net"
            port: "80"
            path: "/attend"
            method: 'POST'
            headers:
                'Content-Type': 'application/json'
                'Content-Length': Buffer.byteLength(post_data)
        , (res)->
            res.setEncoding "utf8"
            res.on "data", (chunk)->
                console.log chunk

        post_req.write post_data
        post_req.end()


card = new Card()

card.readCard()
