import AVFoundation

class LED {

    static let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

    class func flash() {
        let device = LED.device
        if device!.torchAvailable {
            dispatch_async(dispatch_get_main_queue(), {
                device!.lockForConfiguration(nil)
                device!.setTorchModeOnWithLevel(0.1, error: nil)
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
