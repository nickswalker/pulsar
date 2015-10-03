import Foundation
import UIKit

public protocol ShardControlDelegate {
    func activatedShardsChanged()
}

@IBDesignable @objc public class ShardControl: UIControl {

    @IBInspectable public var numberOfShards: Int = 6 {
        didSet {
            if numberOfShards < minShards {
                self.numberOfShards = minShards
            }
            if numberOfShards > maxShards {
                self.numberOfShards = maxShards
            }
            setupShards()
        }
    }

    public var activeShard: Int? {
        willSet(newValue) {
            //Deactivate all because only one can be active at a time
            if activeShard != nil {
                //At slow tempos the active shard may have been removed by the time the next beat happens. Bounds check the array first.
                if activeShard < layers.count {
                    layers[activeShard!].active = false
                }
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

    public var radius: CGFloat = 0.0 {
        didSet(oldValue){
            for layer in layers {
                CATransaction.begin()
                CATransaction.setAnimationDuration(1.0)
                layer.radius = radius
                CATransaction.commit()
            }
        }
    }

    public var activated: UInt = 0b0 {
        didSet(oldValue){
            delegate?.activatedShardsChanged()
        }
    }

    public var delegate: ShardControlDelegate?
    private let doubleTapRecognizer = UITapGestureRecognizer()
    private var layers = [ShardLayer]()
    private var backgroundFlashLayer = BackgroundLayer()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.addTarget(self, action: "handleDoubleTap:")
        autoresizesSubviews = true
        layer.insertSublayer(backgroundFlashLayer, atIndex: 0)
        addGestureRecognizer(doubleTapRecognizer)

        setupShards()
    }
    public override func layoutSublayersOfLayer(layer: CALayer) {

        if layer == self.layer {
            for targetLayer in layers {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                targetLayer.frame = frame
                targetLayer.contentsScale = contentScaleFactor
                CATransaction.commit()
            }
            backgroundFlashLayer.frame = layer.frame
        } else {
            super.layoutSublayersOfLayer(layer)
        }
    }


    private func setupShards() {
        //Adjust numbers as needed
        var toAdd: Int
        let currentNumber = layers.count
        if numberOfShards > currentNumber {
            toAdd = numberOfShards - currentNumber
            addSublayers(toAdd)
        } else if numberOfShards < currentNumber {
            let toRemove = currentNumber - numberOfShards
            removeSublayers(toRemove)
        }
    }

    private func addSublayers(count: Int) {

        for var i = 0; i < count; i++ {
            let tempLayer = ShardLayer()
            tempLayer.frame = frame
            tempLayer.radius = radius
            tempLayer.endAngle = CGFloat(M_PI) * 3
            tempLayer.startAngle = CGFloat(M_PI) * 3
            tempLayer.contentsScale = contentScaleFactor
            layer.addSublayer(tempLayer)
            layer.insertSublayer(tempLayer, atIndex: 1) //Above the backgroundlayer but below the other shards
            layers.append(tempLayer)
        }
        adjustSublayerAngles()
    }

    /**
    Removes from the end of the layers array

    - parameter count: number to remove
    */
    private func removeSublayers(count: Int) {
        for var i = 0; i < count; i++ {
            let targetLayer = layers.last!
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                targetLayer.removeFromSuperlayer()

            })
            CATransaction.setAnimationDuration(0.8)
            targetLayer.endAngle = CGFloat(M_PI) * 3
            targetLayer.startAngle = CGFloat(M_PI) * 3

            CATransaction.commit()

            self.layers.removeLast()
        }
        adjustSublayerAngles()
    }

    //MARK: Overrides

    override public func didMoveToWindow() {
        if let window = window {
            contentScaleFactor = window.screen.scale
        }
    }

    override public func tintColorDidChange() {
        super.tintColorDidChange()
        ShardLayer.accentFillColor = tintColor.colorWithAlphaComponent(0.05).CGColor
    }

    private func adjustSublayerAngles() {
        //Set the angle on all shards
        let accents = activated
        let theta: CGFloat = (CGFloat(M_PI) * 2) / CGFloat(numberOfShards)
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.8)
        for var i = 0; i < layers.count; ++i {
            let targetLayer = layers[i]


            //We'll offset by pi to start the sectors in the center-left
            targetLayer.startAngle = theta * CGFloat(i) + CGFloat(M_PI)
            targetLayer.endAngle = theta * CGFloat(i + 1) + CGFloat(M_PI)


            if accents & UInt(1 << i) > 0 {
                targetLayer.accent = true
            }
            targetLayer.flashStroke()

        }
            CATransaction.commit()
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

    func flashBackground(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundFlashLayer.backgroundColor = UIColor.whiteColor().CGColor
        CATransaction.commit()
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        backgroundFlashLayer.backgroundColor = UIColor.clearColor().CGColor
        CATransaction.commit()
    }

    func handleDoubleTap(recognizer: UIGestureRecognizer) {
        var targetShard: ShardLayer?
        if recognizer.state == .Ended {
            let point = recognizer.locationInView(self)
            targetShard = layer.hitTest(point) as? ShardLayer
            if targetShard != nil {
                targetShard!.accent = !targetShard!.accent
                for var i = 0; i < layers.count; i++ {
                    let targetLayer = layers[i]
                    if targetLayer == targetShard {
                        let value: UInt = targetShard!.accent ? 1 : 0
                        let shifted: UInt = value << UInt(i)
                        let mask:UInt = ~(1 << UInt(i))
                        let newAccents = (activated & mask) | shifted
                        activated = newAccents
                        break
                    }
                }
            }
        }
    }
}