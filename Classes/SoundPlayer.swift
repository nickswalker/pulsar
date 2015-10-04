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

    static var digitalVoice = false {
        willSet(newValue){
            if (newValue != digitalVoice){
                if newValue {
                    setVoice("digital")
                } else {
                    setVoice(nil)
                }
            }
        }
    }

    static var buffers: [PulseType: AVAudioPCMBuffer] = [.Accent: AVAudioPCMBuffer(),
        .Beat: AVAudioPCMBuffer(),
        .Division: AVAudioPCMBuffer(),
        .Subdivision: AVAudioPCMBuffer(),
        .Triplet: AVAudioPCMBuffer()]
    static let players: [PulseType: AVAudioPlayerNode] = [.Accent: AVAudioPlayerNode(),
        .Beat: AVAudioPlayerNode(),
        .Division: AVAudioPlayerNode(),
        .Subdivision: AVAudioPlayerNode(),
        .Triplet: AVAudioPlayerNode()]

    class func setup(){
        setVoice(digitalVoice ? "digital" : nil)
        for (_, node) in players{
            attachAndConnectNodeToMainMixer(node)
        }
        do {
            try SoundPlayer.engine.start()
        } catch _ {
        }
        for (_, node) in players{
            node.play()
        }

    }


    class func schedule(type: PulseType) {
        players[type]!.scheduleBuffer(buffers[type]!, atTime: nil, options: .Interrupts, completionHandler: nil)
    }

    class func vibrate() {
    }

    class func getAudioFormat() -> (AVAudioFormat) {
        let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(PulseType.Beat.rawValue, ofType: "wav")!)
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

    class private func setVoice(voice: String?){
        let prefix: String
        if voice != nil{
            prefix = "\(voice!)-"
        } else {
            prefix = ""
        }
        for (pulse, _) in buffers {
            let fileName = "\(prefix)\(pulse.rawValue)"
            buffers[pulse] = fillWithFile(fileName)
        }
    }
}
