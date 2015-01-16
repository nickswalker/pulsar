public class SlideStepper: UIControl {

    private let labelFontSize = 84
    let defaultValue = 60
    var label = UILabel()
    var stepper = UIStepper()
    var maximumValue: Int = 300
    var minimumValue: Int = 20

    public var value: Int {
        get {
            return Int(stepper.value)
        }
        set(newValue) {
            let valueToSet: Int = {
            if newValue > self.maximumValue {
                return self.maximumValue
            } else if newValue < self.minimumValue {
                return self.minimumValue
            } else{
                return newValue
                }}()
            label.text = "\(Int(valueToSet))"
            stepper.value = Double(valueToSet)
        }
    }
    private var recognizer = UIPanGestureRecognizer()

    override init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 180, height: 140))
        commonInit()
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
        recognizer.addTarget(self, action: "handlePan:")
        recognizer.maximumNumberOfTouches = 1

        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        label.font = UIFont(name: "AvenirNext-UltraLight", size: CGFloat(labelFontSize))
        label.text = "\(defaultValue)"

        stepper.addTarget(self, action: "stepperValueChanged:", forControlEvents: .ValueChanged)

        stepper.maximumValue = Double(maximumValue)
        stepper.minimumValue = Double(minimumValue)
        stepper.stepValue = 1.0
        value = defaultValue

        addSubview(stepper)
        addSubview(label)
        addGestureRecognizer(recognizer)

        stepper.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.setTranslatesAutoresizingMaskIntoConstraints(false)

        addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: stepper, attribute: .CenterX, multiplier: 1.0, constant: 1.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: label, attribute: .CenterX, multiplier: 1.0, constant: 1.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: label, attribute: .Top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: stepper, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0))
    }

    override public func intrinsicContentSize() -> CGSize {
        return CGSize(width: 110, height: 150)
    }

    func stepperValueChanged(sender: UIStepper) {
        label.text = "\(Int(stepper.value))"
        sendActionsForControlEvents(.ValueChanged)
    }

    func handlePan(recognizer: UIPanGestureRecognizer) {
        var translation = recognizer.translationInView(self)
        var affector = Double(-1.0 * translation.y / 8.5)
        value = Int(Double(value) - affector)
        recognizer.setTranslation(CGPoint(x: 0, y: 0), inView: self)
        sendActionsForControlEvents(.ValueChanged)
    }

}