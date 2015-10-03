import Foundation
import UIKit
import AVFoundation

@objc class SoundPlayer: NSObject {
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

    class func playBeat() {
        SoundPlayer.beatPlayer.scheduleBuffer(SoundPlayer.beat, atTime: nil, options: .Interrupts, completionHandler: nil)
    }

    class func playAccent() {
        SoundPlayer.accentPlayer.scheduleBuffer(SoundPlayer.accent, atTime: nil, options: .Interrupts, completionHandler: nil)
    }

    class func playDivision() {
        SoundPlayer.divisionPlayer.scheduleBuffer(SoundPlayer.division, atTime: nil, options: .Interrupts, completionHandler: nil)
    }

    class func playSubdivision() {
        SoundPlayer.subdivisionPlayer.scheduleBuffer(SoundPlayer.subdivision, atTime: nil, options: .Interrupts, completionHandler: nil)
    }

    class func playTriplet() {
        SoundPlayer.tripletPlayer.scheduleBuffer(SoundPlayer.triplet, atTime: nil, options: .Interrupts, completionHandler: nil)
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
        var file = try? AVAudioFile(forReading: url)
        var buffer = AVAudioPCMBuffer(PCMFormat: file!.processingFormat, frameCapacity: UInt32(file!.length))
        do {
            try file!.readIntoBuffer(buffer)
        } catch _ {
        }
        return buffer

    }
}
