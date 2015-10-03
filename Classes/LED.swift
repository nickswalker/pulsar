import AVFoundation

class LED {

    static let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

    class func flash() {
        let device = LED.device
        if device!.torchAvailable {
            dispatch_async(dispatch_get_main_queue(), {
                do {
                    try device!.lockForConfiguration()
                } catch _ {
                }
                do {
                    try device!.setTorchModeOnWithLevel(0.1)
                } catch _ {
                }
                device!.torchMode = .Off
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
