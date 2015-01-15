@objc public protocol MetronomeControlDelegate {
    func switchToggled(sender: UISwitch)
    func bpmChanged(sender: SlideStepper)
}

@IBDesignable public class MetronomeControl: UIControl {

    public enum NoteValue: Int {
        case whole = 1,
             half = 2,
             quarter = 4,
             eigth = 8,
             sixteenth = 16,
             thirtysecond = 32

        func doubleValue() -> Double {
            return 1.0 / Double(self.rawValue)
        }

    }

    public struct TimeSignature {
        public var beatsInABar: Int
        public var noteValueForBeat: NoteValue

        public init(_ beatsInABar: Int, _ noteValueForBeat: NoteValue) {
            self.beatsInABar = beatsInABar
            self.noteValueForBeat = noteValueForBeat
        }
        public init(beatsInABar: Int, noteValueForBeat: NoteValue) {
            self.beatsInABar = beatsInABar
            self.noteValueForBeat = noteValueForBeat
        }
    }

    var bpmControl = SlideStepper()

    public var delegate: MetronomeControlDelegate? {
        didSet {
            runningSwitch.addTarget(delegate, action: "switchToggled:", forControlEvents: .ValueChanged)
            bpmControl.addTarget(delegate, action: "bpmChanged:", forControlEvents: .ValueChanged)
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
        super.init(coder: aDecoder)
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

        runningSwitch.setTranslatesAutoresizingMaskIntoConstraints(false)
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