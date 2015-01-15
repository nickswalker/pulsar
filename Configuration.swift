import Foundation

struct Configuration {
    static let commonConfigurations = [Configuration(beats: 4), Configuration(beats: 2), Configuration(beats: 6, accents:0b10010), Configuration(beats: 9, accents:0b10010010)]
    let beats: Int
    let accents: Int
    init(beats:Int, accents: Int = 0b10){
        self.beats = beats
        self.accents = accents
    }

}