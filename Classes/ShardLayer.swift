import Foundation
import QuartzCore
import UIKit

@objc internal class ShardLayer: CALayer {

    @NSManaged var fillColor: CGColor
    private var strokeColor = ClassMembers.normalStrokeColor
    private let strokeWidth: CGFloat = 2

    @NSManaged var startAngle: CGFloat
    @NSManaged var endAngle: CGFloat

    var tintColor: CGColor = ClassMembers.defaultTintColor {
        didSet(newValue){
            ClassMembers.accentFillColor = UIColor(CGColor: newValue).colorWithAlphaComponent(0.025).CGColor
        }
    }

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
        static let normalStrokeColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1.025).CGColor
        static let animatedStrokeColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1.1).CGColor
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
                fillColor = newColor
            } else {
                let newColor = accent ? ClassMembers.accentFillColor : ClassMembers.normalFillColor
                fillColor = newColor
            }

        }
    }
    var accent: Bool = false {
        willSet(newValue) {
            if newValue == true {
                fillColor = ClassMembers.accentFillColor
            } else {
                fillColor = ClassMembers.normalFillColor
            }
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
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        fillColor = ClassMembers.normalFillColor
        startAngle = 0.0
        endAngle = 0.0
    }

    // MARK: Drawing

    override func drawInContext(ctx: CGContextRef) {
        var test = 0
        let presentation = presentationLayer() as? ShardLayer

        // Create the path
        var center = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
        var radius: CGFloat = 500

        var newPath = CGPathCreateMutable()
        CGPathMoveToPoint(newPath, nil, center.x, center.y)
        var x1 = Double(center.x) + Double(cosf(Float(startAngle)) * 70)
        var y1 = Double(center.y) + Double(sinf(Float(startAngle)) * 70)
        var p1 = CGPoint(x: x1, y: y1)
        CGPathAddLineToPoint(newPath, nil, p1.x, p1.y)

        var clockwise = endAngle < startAngle
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
        animation.duration = CATransaction.animationDuration()
        animation.timingFunction = CATransaction.animationTimingFunction()

        let presentation = presentationLayer() as? ShardLayer
        switch (event) {
            case "startAngle":
                fallthrough
            case "endAngle":
                let flashStroke = CAKeyframeAnimation(keyPath: "strokeColor")
                flashStroke.values = [ClassMembers.normalStrokeColor, ClassMembers.animatedStrokeColor, ClassMembers.normalStrokeColor]
                flashStroke.duration = animation.duration
                addAnimation(flashStroke, forKey: "strokeColor")
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.fromValue = presentation?.endAngle
                return animation
            default:
                return super.actionForKey(event)
        }
    }

    override class func needsDisplayForKey(key: String!) -> Bool {
        let exists = contains(ClassMembers.customPropertyKeys, key)
        return exists || superclass()!.needsDisplayForKey(key)
    }

    override func hitTest(p: CGPoint) -> CALayer! {
        if CGPathContainsPoint(path, nil, p, true) {
            return self
        } else {
            return nil
        }
    }
}
