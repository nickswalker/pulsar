import Foundation
import UIKit

@IBDesignable @objc public class ShardControl: UIControl {

    @IBInspectable public var numberOfShards: Int = 6 {
        willSet(newValue) {
            if newValue < minShards {
                self.numberOfShards = minShards
            }
            if newValue > maxShards {
                self.numberOfShards = maxShards
            }
        }
        didSet {
            setupShards()
        }
    }

    public var activeShard: Int? {
        willSet(newValue) {
            //Deactivate all because only one can be active at a time
            if activeShard != nil {
                // FIX ME: At slow tempos the active shard may have been removed by the time the next beat happens. Bounds check the array first.
                layers[activeShard!].active = false
            }
            //Activate the correct one
            if newValue != nil {
                let targetLayer = layers[newValue!]
                targetLayer.active = true
            }
            self.activeShard = newValue
        }
    }

    public var maxShards: Int = 12 {
        willSet(newValue) {
            if newValue < minShards {
                self.maxShards = minShards + 1
            }
            if numberOfShards > newValue {
                numberOfShards = maxShards
            }
        }
    }

    public var minShards: Int = 1 {
        willSet(newValue) {
            if newValue > maxShards {
                self.minShards = maxShards - 1
            }
            if numberOfShards < newValue {
                numberOfShards = newValue
            }
        }
    }

    var radius: CGFloat = 0.0 {
        didSet(oldValue){
            for layer in layers {
                CATransaction.begin()
                CATransaction.setAnimationDuration(1.0)
                layer.radius = radius
            }
        }
    }
    private let doubleTapRecognizer = UITapGestureRecognizer()
    private let defaults = NSUserDefaults.standardUserDefaults()
    private var layers = [ShardLayer]()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.addTarget(self, action: "handleDoubleTap:")
    
        addGestureRecognizer(doubleTapRecognizer)
        setupShards()
    }

    private func setupShards() {
        //Adjust numbers as needed
        var toAdd: Int
        let currentNumber = layers.count
        if numberOfShards > currentNumber {
            toAdd = numberOfShards - currentNumber
            addSublayers(toAdd)
        } else if numberOfShards < currentNumber {
            var toRemove = currentNumber - numberOfShards
            removeSublayers(toRemove)
        }
        adjustSublayerAngles()
    }

    private func addSublayers(count: Int) {
        for var i = 0; i < count; i++ {
            var tempLayer = ShardLayer()
            tempLayer.frame = frame
            tempLayer.radius = radius
            tempLayer.contentsScale = contentScaleFactor
            layer.addSublayer(tempLayer)
            layers.append(tempLayer)
        }
    }

    /**
    Removes from the end of the layers array

    :param: count number to remove
    */
    private func removeSublayers(count: Int) {
        for var i = 0; i < count; i++ {
            var targetLayer = layers.last!
            targetLayer.removeFromSuperlayer()
            layers.removeLast()
        }
    }

    //MARK: Overrides

    override public func didMoveToWindow() {
        if let window = window {
            contentScaleFactor = window.screen.scale
        }
    }

    override public func tintColorDidChange() {
        super.tintColorDidChange()
        ShardLayer.ClassMembers.accentFillColor = tintColor.colorWithAlphaComponent(0.05).CGColor
    }

    private func adjustSublayerAngles() {
        //Set the angle on all shards
        let accents = UInt16(defaults.objectForKey("accents") as UInt)
        let theta: CGFloat = (CGFloat(M_PI) * 2) / CGFloat(numberOfShards)
        for var i = 0; i < layers.count; ++i {
            let targetLayer = layers[i]

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            targetLayer.frame = frame
            targetLayer.contentsScale = contentScaleFactor
            CATransaction.commit()
            CATransaction.setAnimationDuration(1.0)
            //We'll offset by pi to start the sectors in the center-left
            targetLayer.startAngle = theta * CGFloat(i) + CGFloat(M_PI)
            targetLayer.endAngle = theta * CGFloat(i + 1) + CGFloat(M_PI)

            if accents & UInt16(1 << i) > 0 {
                targetLayer.accent = true
            }
            targetLayer.flashStroke()

        }
    }

    public func addShard() {
        if numberOfShards == maxShards {
            numberOfShards = minShards
        } else {
            ++numberOfShards
        }
        activeShard = 0
    }

    // MARK: State Changers

    public func activateNext() {
        if activeShard != nil {
            //Check if advancing the activeShard would go over the number of shards, if so reset to 0
            if (activeShard! + 1) > (numberOfShards - 1) {
                activeShard = 0
            } else {
                activeShard = activeShard! + 1
            }
        } else {
            activeShard = 0
        }
    }

    public func activeIsAccent() -> Bool {
        if activeShard != nil {
            let activeLayer = layers[activeShard!] as ShardLayer
            return activeLayer.accent
        }
        return false
    }

    func handleDoubleTap(recognizer: UIGestureRecognizer) {
        var targetShard: ShardLayer?
        if recognizer.state == .Ended {
            let point = recognizer.locationInView(self)
            targetShard = layer.hitTest(point) as? ShardLayer
            if targetShard != nil {
                targetShard!.accent = !targetShard!.accent
                targetShard!.setNeedsDisplay()
                for var i = 0; i < layers.count; i++ {
                    var targetLayer = layers[i]
                    if targetLayer == targetShard {
                        let accents = UInt16(defaults.objectForKey("accents") as UInt)
                        let value: UInt16 = targetShard!.accent ? 1 : 0
                        let shifted: UInt16 = value << UInt16(i)
                        let mask:UInt16 = ~(1 << UInt16(i))
                        let newAccents = (accents & mask) | shifted
                        defaults.setObject(UInt(newAccents), forKey: "accents")
                        defaults.synchronize()
                        break
                    }
                }
            }
        }
    }
}