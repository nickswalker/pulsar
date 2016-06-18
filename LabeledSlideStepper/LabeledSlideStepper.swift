@objc public protocol LabeledSlideStepperDelegate {
    func switchToggled(sender: UISwitch)
    func bpmChanged(sender: SlideStepper)
}

@IBDesignable public class LabeledSlideStepper: UIControl {

    var bpmControl = SlideStepper()

    public var delegate: LabeledSlideStepperDelegate? {
        didSet {
            runningSwitch.addTarget(delegate, action: #selector(delegate?.switchToggled), forControlEvents: .ValueChanged)
            bpmControl.addTarget(delegate, action: #selector(delegate?.bpmChanged(_:)), forControlEvents: .ValueChanged)
        }
    }
    var runningSwitch = UISwitch()

    public var running: Bool {
        get {
            return runningSwitch.on
        }
        set(newValue) {
            runningSwitch.on = newValue
        }
    }

    public var bpm: Int {
        get {
            return bpmControl.value
        }
        set(newValue) {
            bpmControl.value = newValue
        }
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    func commonInit() {
        runningSwitch.onTintColor = tintColor
        bpmControl.tintColor = tintColor
        runningSwitch.on = false
        self.addSubview(bpmControl)
        self.addSubview(runningSwitch)

        runningSwitch.translatesAutoresizingMaskIntoConstraints = false
        //setTranslatesAutoresizingMaskIntoConstraints(false)

        addConstraint(NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: bpmControl, attribute: .Top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: runningSwitch, attribute: .CenterX, multiplier: 1.0, constant: 1.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: bpmControl, attribute: .CenterX, multiplier: 1.0, constant: 1.0))
        addConstraint(NSLayoutConstraint(item: bpmControl, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: runningSwitch, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: -20))

    }

    public override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 110, height: 200)
    }

    override public func tintColorDidChange() {
        let isInactive = tintAdjustmentMode == .Dimmed
        if isInactive {
            runningSwitch.onTintColor = UIColor.grayColor()
        } else {
            runningSwitch.onTintColor = tintColor
            bpmControl.tintColor = tintColor
        }
    }
}