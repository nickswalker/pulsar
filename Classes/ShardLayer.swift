import Foundation
import QuartzCore
import UIKit

@objc internal class ShardLayer: CALayer {

    @NSManaged var fillColor: CGColor
    @NSManaged var strokeColor: CGColor
    @NSManaged var startAngle: CGFloat
    @NSManaged var endAngle: CGFloat
    @NSManaged var radius: CGFloat

    fileprivate let strokeWidth: CGFloat = 2
    @objc var center: CGPoint = CGPoint()

        static let customPropertyKeys: [String] = {
            var count: UInt32 = 0
            var keys = [String]()
            let properties = class_copyPropertyList(ShardLayer.self, &count)
            for i: UInt32 in 0 ..< count {
                let property = property_getName((properties?[Int(i)])!)
                keys.append(NSString(cString: property, encoding: String.Encoding.utf8.rawValue)! as String)
            }
            return keys
        }()

    static let normalStrokeColor = UIColor(white: 0.3, alpha: 1.0).cgColor
    static let animatedStrokeColor = UIColor(white: 0.5, alpha: 1.0).cgColor
    static let normalFillColor = UIColor.clear.cgColor
    static let activeFillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.05).cgColor
    static var accentFillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.025).cgColor
    static let accentActiveFillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).cgColor
    static let defaultTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.025).cgColor

    @objc var path: CGPath? = nil
    @objc var active: Bool = false {
        willSet(newValue) {
            if newValue == true {
                let newColor = accent ? ShardLayer.accentActiveFillColor : ShardLayer.activeFillColor
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                fillColor = newColor
                CATransaction.commit()
            } else {
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.3)
                let newColor = accent ? ShardLayer.accentFillColor : ShardLayer.normalFillColor
                fillColor = newColor
                CATransaction.commit()
            }

        }
    }
    @objc var accent: Bool = false {
        willSet(newValue) {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.5)
            if newValue == true {
                let newColor = active ? ShardLayer.accentActiveFillColor : ShardLayer.accentFillColor
                fillColor = newColor
            } else {
                let newColor = active ? ShardLayer.activeFillColor : ShardLayer.normalFillColor
                fillColor = newColor

            }
            CATransaction.commit()
        }
    }
    override init() {
        super.init()
        commonInit()
    }

    override init(layer: Any) {
        super.init(layer: layer)
        if layer is ShardLayer {
            let shard = layer as! ShardLayer
            for property in ShardLayer.customPropertyKeys {
                let value: AnyObject? = shard.value(forKey: property) as AnyObject?
                setValue(value, forKey: property)
            }
            center = shard.center
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        fillColor = ShardLayer.normalFillColor
        strokeColor = ShardLayer.normalStrokeColor
        startAngle = 0.0
        endAngle = 0.0
        radius = 0.0
    }

    override func layoutSublayers() {
        center = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    // MARK: Drawing

    override func draw(in ctx: CGContext) {
        // Create the path

        let newPath = CGMutablePath()

        newPath.move(to: CGPoint(x: center.x, y: center.y))
        let x1 = Double(center.x) + Double(cos(startAngle) * radius)
        let y1 = Double(center.y) + Double(sin(startAngle) * radius)
        let p1 = CGPoint(x: x1, y: y1)
        newPath.addLine(to: CGPoint(x: p1.x, y: p1.y))

        let clockwise = endAngle < startAngle
        newPath.addArc(center: CGPoint(x: center.x, y: center.y), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)

        ctx.addPath(newPath)

        // Color it
        ctx.setFillColor(fillColor)
        ctx.setStrokeColor(strokeColor)
        ctx.setLineWidth(strokeWidth)

        ctx.saveGState()
            // configure context the same as uipath
            ctx.setLineWidth(2.0);
            ctx.setLineJoin(CGLineJoin.miter);
            ctx.setLineCap(CGLineCap.butt);
            ctx.setMiterLimit(10);
            ctx.setFlatness(0.6);
            ctx.drawPath(using: CGPathDrawingMode.fillStroke)
            ctx.restoreGState();



        path = newPath
    }

    override func action(forKey event: String) -> CAAction? {
        let animation = CABasicAnimation(keyPath: event)
        animation.isRemovedOnCompletion = true
        animation.duration = CATransaction.animationDuration()
        animation.timingFunction = CATransaction.animationTimingFunction()

        let presentation = self.presentation()
        switch (event) {
            case "radius":
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.fromValue = presentation?.radius
            return animation
            case "strokeColor":
                animation.fromValue = presentation?.strokeColor
                return animation
            case "startAngle":
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                animation.fromValue = presentation?.startAngle
                return animation
            case "endAngle":
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                animation.fromValue = presentation?.endAngle
                return animation
            default:
                return super.action(forKey: event)
        }
    }

    func flashStroke(){
        let strokeFlash = CAKeyframeAnimation(keyPath: "strokeColor")

        //Get presentation layer
        let pres = self.presentation()
        let currentStrokeColor: CGColor
        if pres != nil{
            currentStrokeColor = pres!.strokeColor
        } else {
            currentStrokeColor = ShardLayer.normalStrokeColor
        }
        strokeFlash.values = [currentStrokeColor,
            ShardLayer.animatedStrokeColor,
            ShardLayer.normalStrokeColor]
        strokeFlash.duration = 1.0
        strokeFlash.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

        add(strokeFlash, forKey: "strokeColor")
    }

    override class func needsDisplay(forKey key: String) -> Bool {
        let exists = ShardLayer.customPropertyKeys.contains(key)
        return exists || superclass()!.needsDisplay(forKey: key)
    }

    override func hitTest(_ p: CGPoint) -> CALayer? {
        if path?.contains(p) ?? false {
            return self
        } else {
            return nil
        }
    }
}
