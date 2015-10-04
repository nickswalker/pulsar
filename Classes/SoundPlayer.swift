import Foundation
import UIKit
import AVFoundation

enum PulseType: String {
    case Accent,
    Beat,
    Division,
    Subdivision,
    Triplet
}

@objc final class SoundPlayer: NSObject {
    static var engine = AVAudioEngine()
    static var accentPlayer = AVAudioPlayerNode()
    static var beatPlayer = AVAudioPlayerNode()
    static var divisionPlayer = AVAudioPlayerNode()
    static var subdivisionPlayer = AVAudioPlayerNode()
    static var tripletPlayer = AVAudioPlayerNode()


    static var accent = AVAudioPCMBuffer()
    static var beat = AVAudioPCMBuffer()
    static var division = AVAudioPCMBuffer()
    static var subdivision = AVAudioPCMBuffer()
    static var triplet = AVAudioPCMBuffer()
    static var digitalVoice = false

    static let buffers: [PulseType: AVAudioPCMBuffer] = [.Accent: accent,
        .Beat: beat,
        .Division: division,
        .Subdivision: subdivision,
        .Triplet: triplet]
    static let players: [PulseType: AVAudioPlayerNode] = [.Accent: accentPlayer,
        .Beat: beatPlayer,
        .Division: divisionPlayer,
        .Subdivision: subdivisionPlayer,
        .Triplet: tripletPlayer]

    class func setup(){
        digitalVoice(SoundPlayer.digitalVoice)
        attachAndConnectNodeToMainMixer(SoundPlayer.accentPlayer)
        attachAndConnectNodeToMainMixer(SoundPlayer.beatPlayer)
        attachAndConnectNodeToMainMixer(SoundPlayer.divisionPlayer)
        attachAndConnectNodeToMainMixer(SoundPlayer.subdivisionPlayer)
        attachAndConnectNodeToMainMixer(SoundPlayer.tripletPlayer)
        do {
            try SoundPlayer.engine.start()
        } catch _ {
        }
        SoundPlayer.accentPlayer.play()
        SoundPlayer.beatPlayer.play()
        SoundPlayer.divisionPlayer.play()
        SoundPlayer.tripletPlayer.play()
        SoundPlayer.subdivisionPlayer.play()

    }

    class func digitalVoice(value: Bool){
        SoundPlayer.digitalVoice = value
        if value {
            SoundPlayer.accent = fillWithFile("digitalAccent")
            SoundPlayer.beat = fillWithFile("digitalBeat")
            SoundPlayer.division = fillWithFile("digitalDivision")
            SoundPlayer.subdivision = fillWithFile("digitalSubdivision")
            SoundPlayer.triplet = fillWithFile("digitalTriplet")
        } else {
            SoundPlayer.accent = fillWithFile("accent")
            SoundPlayer.beat = fillWithFile("beat")
            SoundPlayer.division = fillWithFile("division")
            SoundPlayer.subdivision = fillWithFile("subdivision")
            SoundPlayer.triplet = fillWithFile("triplet")
        }
    }

    class func getDigitalVoice() -> Bool {
        return SoundPlayer.digitalVoice
    }

    class func schedule(type: PulseType) {
        players[type]!.scheduleBuffer(buffers[type]!, atTime: nil, options: .Interrupts, completionHandler: nil)
    }

    class func vibrate() {
    }

    class func getAudioFormat() -> (AVAudioFormat) {
        let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beat", ofType: "wav")!)
        let file = try? AVAudioFile(forReading: url)
        return file!.processingFormat

    }

    class private func attachAndConnectNodeToMainMixer(node: AVAudioNode) {
        SoundPlayer.engine.attachNode(node)
        SoundPlayer.engine.connect(node, to: SoundPlayer.engine.mainMixerNode, format: getAudioFormat())
    }

    class private func fillWithFile(fileName: String) -> (AVAudioPCMBuffer) {
        let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fileName, ofType: "wav")!)
        let file = try? AVAudioFile(forReading: url)
        let buffer = AVAudioPCMBuffer(PCMFormat: file!.processingFormat, frameCapacity: UInt32(file!.length))
        do {
            try file!.readIntoBuffer(buffer)
        } catch _ {
        }
        return buffer

    }
}
