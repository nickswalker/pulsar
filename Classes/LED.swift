import AVFoundation

class LED {

    private struct ClassMembers{
        static let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    }

    class func flash() {
        let device = ClassMembers.device
        if device.hasTorch && device.torchAvailable {
            let delayInSeconds = 0.1;
            let delay = Int64(delayInSeconds * Double(NSEC_PER_SEC))
            let currentTime = dispatch_time_t(DISPATCH_TIME_NOW)
            let popTime = dispatch_time(currentTime, delay);
            dispatch_after(popTime, dispatch_get_main_queue(), {
                device.lockForConfiguration(nil)
                device.setTorchModeOnWithLevel(0.1, error: nil)
                device.torchMode = .Off
                device.unlockForConfiguration()
            })

        }
    }
}
