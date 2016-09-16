@objc public protocol LabeledSlideStepperDelegate {
    func switchToggled(_ sender: UISwitch)
    func bpmChanged(_ sender: SlideStepper)
}

@IBDesignable open class LabeledSlideStepper: UIControl {

    var bpmControl = SlideStepper()

    open var delegate: LabeledSlideStepperDelegate? {
        didSet {
            runningSwitch.addTarget(delegate, action: #selector(delegate?.switchToggled), for: .valueChanged)
            bpmControl.addTarget(delegate, action: #selector(delegate?.bpmChanged(_:)), for: .valueChanged)
        }
    }
    var runningSwitch = UISwitch()

    open var running: Bool {
        get {
            return runningSwitch.isOn
        }
        set(newValue) {
            runningSwitch.isOn = newValue
        }
    }

    open var bpm: Int {
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
        runningSwitch.isOn = false
        self.addSubview(bpmControl)
        self.addSubview(runningSwitch)

        runningSwitch.translatesAutoresizingMaskIntoConstraints = false
        //setTranslatesAutoresizingMaskIntoConstraints(false)

        addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: bpmControl, attribute: .top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: runningSwitch, attribute: .centerX, multiplier: 1.0, constant: 1.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: bpmControl, attribute: .centerX, multiplier: 1.0, constant: 1.0))
        addConstraint(NSLayoutConstraint(item: bpmControl, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: runningSwitch, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: -20))

    }

    open override var intrinsicContentSize : CGSize {
        return CGSize(width: 110, height: 200)
    }

    override open func tintColorDidChange() {
        let isInactive = tintAdjustmentMode == .dimmed
        if isInactive {
            runningSwitch.onTintColor = UIColor.gray
        } else {
            runningSwitch.onTintColor = tintColor
            bpmControl.tintColor = tintColor
        }
    }
}
