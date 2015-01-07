import Foundation
import UIKit
import AVFoundation

@objc class SoundPlayer: NSObject {
    var engine = AVAudioEngine()
    var accentPlayer = AVAudioPlayerNode()
    var beatPlayer = AVAudioPlayerNode()
    var divisionPlayer = AVAudioPlayerNode()
    var subdivisionPlayer = AVAudioPlayerNode()
    var tripletPlayer = AVAudioPlayerNode()

    let accent = AVAudioPCMBuffer()
    let beat = AVAudioPCMBuffer()
    let division = AVAudioPCMBuffer()
    let subdivision = AVAudioPCMBuffer()
    let triplet = AVAudioPCMBuffer()
    let defaults = NSUserDefaults.standardUserDefaults()
    override init() {

        super.init()
        if defaults.boolForKey("digitalVoice") {
            accent = fillWithFile("digitalAccent")
            beat = fillWithFile("digitalBeat")
            division = fillWithFile("digitalDivision")
            subdivision = fillWithFile("digitalSubdivision")
            triplet = fillWithFile("digitalTriplet")
        } else {
            accent = fillWithFile("accent")
            beat = fillWithFile("beat")
            division = fillWithFile("division")
            subdivision = fillWithFile("subdivision")
            triplet = fillWithFile("triplet")
        }
        attachAndConnectNodeToMainMixer(accentPlayer)
        attachAndConnectNodeToMainMixer(beatPlayer)
        attachAndConnectNodeToMainMixer(divisionPlayer)
        attachAndConnectNodeToMainMixer(subdivisionPlayer)
        attachAndConnectNodeToMainMixer(tripletPlayer)
        engine.startAndReturnError(nil)


    }

    func playBeat() {

        beatPlayer.scheduleBuffer(beat, atTime: nil, options: .Interrupts, completionHandler: nil)
        beatPlayer.play()
    }

    func playAccent() {
        accentPlayer.scheduleBuffer(accent, atTime: nil, options: .Interrupts, completionHandler: nil)
        accentPlayer.play()
    }

    func playDivision() {
        divisionPlayer.scheduleBuffer(division, atTime: nil, options: .Interrupts, completionHandler: nil)
        divisionPlayer.play()
    }

    func playSubdivision() {
        subdivisionPlayer.scheduleBuffer(subdivision, atTime: nil, options: .Interrupts, completionHandler: nil)
        subdivisionPlayer.play()
    }

    func playTriplet() {
        tripletPlayer.scheduleBuffer(triplet, atTime: nil, options: .Interrupts, completionHandler: nil)
        tripletPlayer.play()
    }

    func vibrate() {
    }

    func getAudioFormat() -> (AVAudioFormat) {
        let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beat", ofType: "wav")!)
        let file = AVAudioFile(forReading: url, error: nil)
        return file.processingFormat

    }

    func attachAndConnectNodeToMainMixer(node: AVAudioNode) {
        engine.attachNode(node)
        engine.connect(node, to: engine.mainMixerNode, format: getAudioFormat())
    }

    func fillWithFile(fileName: String) -> (AVAudioPCMBuffer) {
        let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fileName, ofType: "wav")!)
        var file = AVAudioFile(forReading: url, error: nil)
        var buffer = AVAudioPCMBuffer(PCMFormat: file.processingFormat, frameCapacity: UInt32(file.length))
        file.readIntoBuffer(buffer, error: nil)
        return buffer;

    }
}
