import Foundation
import QuartzCore
import UIKit

class ShardLayer: CALayer {

    // MARK: Types

    struct SharedColors {
        static let defaultTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.025)
    }

    var tintColor: UIColor = SharedColors.defaultTintColor {
        didSet(newValue){
            accentFillColor = newValue.colorWithAlphaComponent(0.025)
        }
    }

    private let normalStrokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.025)
    private let normalFillColor = UIColor.clearColor()
    private let activeFillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.05)
    private var accentFillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.025)
    private let accentActiveFillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)

    private var fillColor = UIColor.redColor()
    private var strokeColor = UIColor.blueColor()
    private var strokeWidth: CGFloat = 1

    var startAngle: CGFloat = 0
    var endAngle: CGFloat = 0

    var path: CGPath? = nil

    var active: Bool = false {
        willSet(newValue) {
            if newValue == true {
                if !accent {
                    fillColor = activeFillColor
                } else {
                    fillColor = accentActiveFillColor
                }
            } else {
                if !accent {
                    fillColor = normalFillColor
                } else {
                    fillColor = accentFillColor
                }

            }
            setNeedsDisplay()
        }
    }
    var accent: Bool = false {
        willSet(newValue) {
            if newValue == true {
                fillColor = accentFillColor
            } else {
                fillColor = normalFillColor
            }
        }
    }
    override init() {
        super.init()
        commonInit()
    }

    override init!(layer: AnyObject!) {
        super.init()
        if layer is ShardLayer {
            let shard = layer as ShardLayer
            frame = shard.frame
            accent = shard.accent
            active = shard.active
            tintColor = shard.tintColor


        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        strokeColor = normalStrokeColor
        active = false
    }

    // MARK: Drawing

    override func drawInContext(ctx: CGContextRef) {
        // Create the path
        var center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
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
        CGContextSetFillColorWithColor(ctx, fillColor.CGColor)
        CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor)
        CGContextSetLineWidth(ctx, strokeWidth)

        CGContextDrawPath(ctx, kCGPathFillStroke)

        path = newPath
    }

    // MARK: Animation
    override func display() {
        //println("displayed!")
        super.display()
    }

    override func actionForKey(event: String!) -> CAAction! {

        let animation = CABasicAnimation(keyPath: event)
        animation.duration = CATransaction.animationDuration()
        animation.timingFunction = CATransaction.animationTimingFunction()
        switch (event) {
            case "fillColor":
                animation.duration = 7.0
                return animation
            case "startAngle":
                fallthrough
            case "endAngle":
                println("Asked for \(event) action")
                return animation
            case "contents":
                return nil
            default:

                return super.actionForKey(event)
        }
    }

    override class func needsDisplayForKey(key: String!) -> Bool {
        if key == "active" {
            return true
        }
        switch (key) {
            case "startAngle":
                fallthrough
            case "accent":
                fallthrough
            case "endAngle":
                fallthrough
            case "active":
                return true
            default:
                return CAShapeLayer.needsDisplayForKey(key)
        }

    }

    override func hitTest(p: CGPoint) -> CALayer! {
        if CGPathContainsPoint(path, nil, p, true) {
            return self
        } else {
            return nil
        }
    }

    func getRandomColor() -> CGColor {

        var randomRed: CGFloat = CGFloat(drand48())

        var randomGreen: CGFloat = CGFloat(drand48())

        var randomBlue: CGFloat = CGFloat(drand48())

        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0).CGColor

    }
}
