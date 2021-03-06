import AVFoundation

class LED {

    static let device = AVCaptureDevice.default(for: AVMediaType.video)

    class func flash() {
        let device = LED.device
        if device!.isTorchAvailable {
            DispatchQueue.main.async(execute: {
                do {
                    try device!.lockForConfiguration()
                } catch _ {
                }
                do {
                    try device!.setTorchModeOn(level: 0.1)
                } catch _ {
                }
                device!.torchMode = .off
                device!.unlockForConfiguration()
            })

        }
    }

    class func hasLED() -> Bool {
        if LED.device != nil {
            return LED.device!.hasFlash
        }
        else {
            return false
        }
    }

}
