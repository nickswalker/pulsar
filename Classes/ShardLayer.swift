import Foundation
import QuartzCore
import UIKit

@objc internal class ShardLayer: CALayer {

    @NSManaged var fillColor: CGColor
    @NSManaged var strokeColor: CGColor
    @NSManaged var startAngle: CGFloat
    @NSManaged var endAngle: CGFloat
    @NSManaged var radius: CGFloat

    private let strokeWidth: CGFloat = 2
    var center: CGPoint = CGPoint()

    struct ClassMembers {
        static let customPropertyKeys: [String] = {
            var count: UInt32 = 0
            var keys = [String]()
            let properties = class_copyPropertyList(ShardLayer.self, &count)
            for var i: UInt32 = 0; i < count; i++ {
                let property = property_getName(properties[Int(i)])
                keys.append(NSString(CString: property, encoding: NSUTF8StringEncoding)!)
            }
            return keys
        }()

        static let normalStrokeColor = UIColor(white: 0.3, alpha: 1.0).CGColor
        static let animatedStrokeColor = UIColor(white: 0.5, alpha: 1.0).CGColor
        static let normalFillColor = UIColor.clearColor().CGColor
        static let activeFillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.05).CGColor
        static var accentFillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.025).CGColor
        static let accentActiveFillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1).CGColor
        static let defaultTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.025).CGColor
    }

    var path: CGPath? = nil
    var active: Bool = false {
        willSet(newValue) {
            if newValue == true {
                let newColor = accent ? ClassMembers.accentActiveFillColor : ClassMembers.activeFillColor
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                fillColor = newColor
                CATransaction.commit()
            } else {
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.3)
                let newColor = accent ? ClassMembers.accentFillColor : ClassMembers.normalFillColor
                fillColor = newColor
                CATransaction.commit()
            }

        }
    }
    var accent: Bool = false {
        willSet(newValue) {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.5)
            if newValue == true {
                let newColor = active ? ClassMembers.accentActiveFillColor : ClassMembers.accentFillColor

                fillColor = newColor
            } else {
                let newColor = active ? ClassMembers.activeFillColor : ClassMembers.normalFillColor

                fillColor = newColor

            }
            CATransaction.commit()
        }
    }
    override init() {
        super.init()
        commonInit()
    }

    override init!(layer: AnyObject!) {
        super.init(layer: layer)
        if layer is ShardLayer {
            let shard = layer as ShardLayer
            for property in ClassMembers.customPropertyKeys {
                let value: AnyObject? = shard.valueForKey(property)
                setValue(value, forKey: property)
            }
            center = shard.center
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        fillColor = ClassMembers.normalFillColor
        strokeColor = ClassMembers.normalStrokeColor
        startAngle = 0.0
        endAngle = 0.0
        radius = 0.0
    }

    override func layoutSublayers() {
        center = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
    }

    // MARK: Drawing

    override func drawInContext(ctx: CGContextRef) {
        // Create the path

        var newPath = CGPathCreateMutable()

        CGPathMoveToPoint(newPath, nil, center.x, center.y)
        let x1 = Double(center.x) + Double(cos(startAngle) * radius)
        let y1 = Double(center.y) + Double(sin(startAngle) * radius)
        let p1 = CGPoint(x: x1, y: y1)
        CGPathAddLineToPoint(newPath, nil, p1.x, p1.y)

        let clockwise = endAngle < startAngle
        CGPathAddArc(newPath, nil, center.x, center.y, radius, startAngle, endAngle, clockwise)

        CGContextAddPath(ctx, newPath)

        // Color it
        CGContextSetFillColorWithColor(ctx, fillColor)
        CGContextSetStrokeColorWithColor(ctx, strokeColor)
        CGContextSetLineWidth(ctx, strokeWidth)

        CGContextDrawPath(ctx, kCGPathFillStroke)

        path = newPath
    }

    override func actionForKey(event: String!) -> CAAction! {
        let animation = CABasicAnimation(keyPath: event)
        animation.removedOnCompletion = true
        animation.duration = CATransaction.animationDuration()
        animation.timingFunction = CATransaction.animationTimingFunction()

        let presentation = presentationLayer() as? ShardLayer
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
                return super.actionForKey(event)
        }
    }

    func flashStroke(){
        let strokeFlash = CAKeyframeAnimation(keyPath: "strokeColor")
        strokeFlash.values = [ClassMembers.normalStrokeColor,
            ClassMembers.animatedStrokeColor,
            ClassMembers.normalStrokeColor]
        strokeFlash.duration = 1.0
        strokeFlash.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

        addAnimation(strokeFlash, forKey: "strokeColor")
    }

    override class func needsDisplayForKey(key: String!) -> Bool {
        let exists = contains(ClassMembers.customPropertyKeys, key)
        return exists || superclass()!.needsDisplayForKey(key)
    }

    override func hitTest(p: CGPoint) -> CALayer! {
        if CGPathContainsPoint(path, nil, p, false) {
            return self
        } else {
            return nil
        }
    }
}
