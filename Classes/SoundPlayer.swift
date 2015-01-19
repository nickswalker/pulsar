import Foundation
import UIKit
import AVFoundation

@objc class SoundPlayer: NSObject {
    private struct ClassMembers {
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
    }

    class func setup(){
        digitalVoice(ClassMembers.digitalVoice)
        attachAndConnectNodeToMainMixer(ClassMembers.accentPlayer)
        attachAndConnectNodeToMainMixer(ClassMembers.beatPlayer)
        attachAndConnectNodeToMainMixer(ClassMembers.divisionPlayer)
        attachAndConnectNodeToMainMixer(ClassMembers.subdivisionPlayer)
        attachAndConnectNodeToMainMixer(ClassMembers.tripletPlayer)
        ClassMembers.engine.startAndReturnError(nil)
        ClassMembers.accentPlayer.play()
        ClassMembers.beatPlayer.play()
        ClassMembers.divisionPlayer.play()
        ClassMembers.tripletPlayer.play()
        ClassMembers.subdivisionPlayer.play()

    }

    class func digitalVoice(value: Bool){
        ClassMembers.digitalVoice = value
        if value {
            ClassMembers.accent = fillWithFile("digitalAccent")
            ClassMembers.beat = fillWithFile("digitalBeat")
            ClassMembers.division = fillWithFile("digitalDivision")
            ClassMembers.subdivision = fillWithFile("digitalSubdivision")
            ClassMembers.triplet = fillWithFile("digitalTriplet")
        } else {
            ClassMembers.accent = fillWithFile("accent")
            ClassMembers.beat = fillWithFile("beat")
            ClassMembers.division = fillWithFile("division")
            ClassMembers.subdivision = fillWithFile("subdivision")
            ClassMembers.triplet = fillWithFile("triplet")
        }
    }

    class func getDigitalVoice() -> Bool {
        return ClassMembers.digitalVoice
    }

    class func playBeat() {
        ClassMembers.beatPlayer.scheduleBuffer(ClassMembers.beat, atTime: nil, options: .Interrupts, completionHandler: nil)
    }

    class func playAccent() {
        ClassMembers.accentPlayer.scheduleBuffer(ClassMembers.accent, atTime: nil, options: .Interrupts, completionHandler: nil)
    }

    class func playDivision() {
        ClassMembers.divisionPlayer.scheduleBuffer(ClassMembers.division, atTime: nil, options: .Interrupts, completionHandler: nil)
    }

    class func playSubdivision() {
        ClassMembers.subdivisionPlayer.scheduleBuffer(ClassMembers.subdivision, atTime: nil, options: .Interrupts, completionHandler: nil)
    }

    class func playTriplet() {
        ClassMembers.tripletPlayer.scheduleBuffer(ClassMembers.triplet, atTime: nil, options: .Interrupts, completionHandler: nil)
    }

    class func vibrate() {
    }

    class func getAudioFormat() -> (AVAudioFormat) {
        let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beat", ofType: "wav")!)
        let file = AVAudioFile(forReading: url, error: nil)
        return file.processingFormat

    }

    class private func attachAndConnectNodeToMainMixer(node: AVAudioNode) {
        ClassMembers.engine.attachNode(node)
        ClassMembers.engine.connect(node, to: ClassMembers.engine.mainMixerNode, format: getAudioFormat())
    }

    class private func fillWithFile(fileName: String) -> (AVAudioPCMBuffer) {
        let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fileName, ofType: "wav")!)
        var file = AVAudioFile(forReading: url, error: nil)
        var buffer = AVAudioPCMBuffer(PCMFormat: file.processingFormat, frameCapacity: UInt32(file.length))
        file.readIntoBuffer(buffer, error: nil)
        return buffer

    }
}
