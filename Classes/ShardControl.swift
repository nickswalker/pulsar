import Foundation
import UIKit

@IBDesignable public class ShardControl: UIControl {

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
        get {
            for var i = 0; i < layers.count; ++i {
                let target = layers[i]
                if target.active {
                    return i
                }
            }
            return nil
        }
        set(newValue) {
            //Deactivate all because only one can be active at a time
            for layer in layers {
                layer.active = false
                //targetLayer.thing = !targetLayer.thing
            }
            //Activate the correct one
            if newValue != nil {
                let targetLayer = layers[newValue!]
                targetLayer.active = true
                //targetLayer.thing = !targetLayer.thing
            }

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

    private let sideLength: CGFloat = 500
    private let longPressRecognizer = UILongPressGestureRecognizer()
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
        longPressRecognizer.minimumPressDuration = 1
        longPressRecognizer.addTarget(self, action: "handleLongPress:")
        addGestureRecognizer(longPressRecognizer)
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
            tempLayer.contentsScale = UIScreen.mainScreen().scale
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
        for layer in layers {
            layer.tintColor = tintColor
        }
    }

    private func adjustSublayerAngles() {
        //Set the angle on all shards
        let theta: CGFloat = (CGFloat(M_PI) * 2) / CGFloat(numberOfShards)
        let accents = defaults.objectForKey("accents") as NSArray
        for var i = 0; i < layers.count; ++i {
            let targetLayer = layers[i]
            targetLayer.frame = frame
            //We'll offset by pi to start the sectors in the upper left corner
            targetLayer.startAngle = theta * CGFloat(i) + CGFloat(M_PI)
            targetLayer.endAngle = theta * CGFloat(i + 1) + CGFloat(M_PI)

            if accents[i] as NSNumber == 1 {
                //layer.accent = true
            }

            targetLayer.setNeedsDisplay()

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

    func handleLongPress(recognizer: UIGestureRecognizer) {
        var targetShard: ShardLayer?
        switch (recognizer.state) {
            case .Began:
                let point = recognizer.locationInView(self)
                targetShard = layer.hitTest(point) as? ShardLayer
                if targetShard != nil {
                    targetShard!.accent = !targetShard!.accent
                    targetShard!.setNeedsDisplay()
                }

            default:
                targetShard = nil
        }
        if targetShard != nil {
            for var i = 0; i < layers.count; i++ {
                var targetLayer = layers[i]
                if targetLayer == targetShard {
                    var accents = defaults.objectForKey("accents") as NSArray
                    var accentsCopy = accents.mutableCopy() as NSMutableArray
                    accentsCopy[i] = targetShard!.accent ? 1 as NSNumber : 0 as NSNumber
                    defaults.setObject(accentsCopy, forKey: "accents")
                    defaults.synchronize()
                    break
                }
            }
        }
    }
}