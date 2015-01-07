import Foundation
import AVFoundation

@objc class LED {
    class func flash() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
        if device != nil {
            if device.hasTorch && device.torchAvailable {
                if (device.hasTorch) {
                    device.lockForConfiguration(nil)
                    device.setTorchModeOnWithLevel(0.1, error: nil)
                    device.unlockForConfiguration()
                }
                device.lockForConfiguration(nil)
                device.setTorchModeOnWithLevel(0.0, error: nil)
                device.unlockForConfiguration()
            }
        }
    }
}
