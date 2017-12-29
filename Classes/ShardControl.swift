import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


public protocol ShardControlDelegate {
    func activatedShardsChanged()
}

@IBDesignable @objc open class ShardControl: UIControl {

    @IBInspectable open var numberOfShards: Int = 6 {
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

    open var activeShard: Int? {
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

    open var maxShards: Int = 12 {
        willSet(newValue) {
            if newValue < minShards {
                self.maxShards = minShards + 1
            }
            if numberOfShards > newValue {
                numberOfShards = maxShards
            }
        }
    }

    open var minShards: Int = 1 {
        willSet(newValue) {
            if newValue > maxShards {
                self.minShards = maxShards - 1
            }
            if numberOfShards < newValue {
                numberOfShards = newValue
            }
        }
    }

    open var radius: CGFloat = 0.0 {
        didSet(oldValue){
            for layer in layers {
                CATransaction.begin()
                CATransaction.setAnimationDuration(1.0)
                layer.radius = radius
                CATransaction.commit()
            }
        }
    }

    open var activated: UInt = 0b0 {
        didSet(oldValue){
            updateAccentDisplay()
        }
    }

    open var delegate: ShardControlDelegate?
    fileprivate let doubleTapRecognizer = UITapGestureRecognizer()
    fileprivate var layers = [ShardLayer]()
    fileprivate var backgroundFlashLayer = BackgroundLayer()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    fileprivate func commonInit() {
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.addTarget(self, action: #selector(ShardControl.handleDoubleTap(_:)))
        autoresizesSubviews = true
        layer.insertSublayer(backgroundFlashLayer, at: 0)
        addGestureRecognizer(doubleTapRecognizer)

        setupShards()
    }
    open override func layoutSublayers(of layer: CALayer) {


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
            super.layoutSublayers(of: layer)
        }
    }


    fileprivate func setupShards() {
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

    fileprivate func updateAccentDisplay(){
        for i in 0 ..< layers.count {
            let targetLayer = layers[i]

            if activated & UInt(1 << i) > 0 {
                targetLayer.accent = true
            } else {
                targetLayer.accent = false
            }
        }
    }

    fileprivate func addSublayers(_ count: Int) {
        for _ in 0 ..< count {
            let tempLayer = ShardLayer()
            tempLayer.frame = frame
            tempLayer.radius = radius
            tempLayer.endAngle = CGFloat.pi * 3
            tempLayer.startAngle = CGFloat.pi * 3
            tempLayer.contentsScale = contentScaleFactor
            layer.addSublayer(tempLayer)
            layer.insertSublayer(tempLayer, at: 1) //Above the backgroundlayer but below the other shards
            layers.append(tempLayer)
        }
        adjustSublayerAngles()
    }

    /**
    Removes from the end of the layers array

    - parameter count: number to remove
    */
    fileprivate func removeSublayers(_ count: Int) {
        for i in 0 ..< count {
            let targetLayer = layers.last!
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                targetLayer.removeFromSuperlayer()
            })
            CATransaction.setAnimationDuration(0.8)
            targetLayer.endAngle = CGFloat.pi * 3
            targetLayer.startAngle = CGFloat.pi * 3

            CATransaction.commit()

            self.layers.removeLast()
        }
        adjustSublayerAngles()
    }

    //MARK: Overrides

    override open func didMoveToWindow() {
        if let window = window {
            contentScaleFactor = window.screen.scale
        }
    }

    override open func tintColorDidChange() {
        super.tintColorDidChange()
        ShardLayer.accentFillColor = tintColor.withAlphaComponent(0.05).cgColor
    }

    fileprivate func adjustSublayerAngles() {
        //Set the angle on all shards
        let accents = activated
        let theta: CGFloat = (CGFloat.pi * 2) / CGFloat(numberOfShards)
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.8)
        for i in 0 ..< layers.count {
            let targetLayer = layers[i]

            //We'll offset by pi to start the sectors in the center-left
            targetLayer.startAngle = theta * CGFloat(i) + CGFloat.pi
            targetLayer.endAngle = theta * CGFloat(i + 1) + CGFloat.pi

            if accents & UInt(1 << i) > 0 {
                targetLayer.accent = true
            }
            targetLayer.flashStroke()

        }
            CATransaction.commit()
    }

    open func addShard() {
        if numberOfShards == maxShards {
            numberOfShards = minShards
        } else {
            numberOfShards += 1
        }
        activeShard = 0
    }

    // MARK: State Changers

    open func activateNext() {
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

    open func activeIsAccent() -> Bool {
        if activeShard != nil {
            let activeLayer = layers[activeShard!] as ShardLayer
            return activeLayer.accent
        }
        return false
    }

    func flashBackground(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundFlashLayer.backgroundColor = UIColor.white.cgColor
        CATransaction.commit()
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
        backgroundFlashLayer.backgroundColor = UIColor.clear.cgColor
        CATransaction.commit()
    }

    @objc func handleDoubleTap(_ recognizer: UIGestureRecognizer) {
        var targetShard: ShardLayer?
        if recognizer.state == .ended {
            let point = recognizer.location(in: self)
            targetShard = layer.hitTest(point) as? ShardLayer
            if targetShard != nil {
                targetShard!.accent = !targetShard!.accent
                for i in 0 ..< layers.count {
                    let targetLayer = layers[i]
                    if targetLayer == targetShard {
                        let value: UInt = targetShard!.accent ? 1 : 0
                        let shifted: UInt = value << UInt(i)
                        let mask:UInt = ~(1 << UInt(i))
                        let newAccents = (activated & mask) | shifted
                        activated = newAccents
                        delegate?.activatedShardsChanged()
                        break
                    }
                }
            }
        }
    }
}
