declare module "libpafe" {
    class Pasori {
        close(): void

        version(): string

        type(): number

        setTimeout(time: Number): void

        polling(systemcode: Number, timeslot: Number, callback: (felica: Felica) => void):void
    }

    interface Felica {
        close(): void

        getIDm(): string|undefined

        getPMm(): string | undefined

        readSingle(servicecode: number, mode: number, addr: number): number[]

        writeSingle(servicecode: number, mode: number, addr: number, data: number[]): void
    }
}