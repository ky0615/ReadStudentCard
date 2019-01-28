import { Pasori, Felica } from "libpafe"
const pasori = new Pasori()

class Card {
    NEXT_SCAN_TIME = 300
    DELETE_IDM_CACHE_TIME = 500

    idmCache: string

    constructor() {
        this.idmCache = ""
    }

    readCard() {
        pasori.setTimeout(60)
        pasori.polling(0xFE00, 0, (felica) => {
            if (!felica) {
                // console.log("felica card is not found")
                this.readCard()
                return
            }

            const idm = felica.getIDm()
            setTimeout(() => this.readCard(), this.NEXT_SCAN_TIME)
            if (idm === this.idmCache) {
                console.log("same card")
                return
            } else if (idm === undefined) {
                console.log("idm get error")
                return
            }

            console.log(`scan card IDm: ${idm}, PWm: ${felica.getPMm()}`)
            this.idmCache = idm
            setTimeout(() => this.deleteIDmCache(), this.DELETE_IDM_CACHE_TIME);
            this.readData(felica)
        })
    }

    readData(felica: Felica) {
        try {
            const number = felica.readSingle(0x1A8B, 0, 0x0000)
                // .filter(s => s != "\0")
                .map((s: number) => String.fromCharCode(s))
                .slice(2,9)
                .join("")
            const name = felica.readSingle(0x1A8B, 0, 0x0001)
                .filter(s => s != 0)
                .map(s => String.fromCharCode(s))
                .join("")
            this.sendCardData({
                number, name
            })
        } catch(e) {
            console.error(e)
        }
    }

    deleteIDmCache() {
        this.idmCache = ""
    }

    sendCardData(payload: {number: string, name: string}) {
        console.log("send!: ", payload);
    }
}

const card = new Card()
card.readCard()
