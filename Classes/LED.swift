import AVFoundation

class LED {

    private struct ClassMembers{
        static let device: AVCaptureDevice? = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    }

    class func flash() {
        let device = ClassMembers.device
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
        if ClassMembers.device != nil {
            return ClassMembers.device!.hasFlash
        }
        else {
            return false
        }
        }

}
