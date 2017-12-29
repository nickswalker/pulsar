open class SlideStepper: UIControl {

    fileprivate let labelFontSize = 84
    let defaultValue = 60
    var label = UILabel()
    var stepper = UIStepper()
    var maximumValue: Int = 300
    var minimumValue: Int = 20

    open var value: Int {
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
    fileprivate var recognizer = UIPanGestureRecognizer()

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    func commonInit() {
        recognizer.addTarget(self, action: #selector(handlePan))
        recognizer.maximumNumberOfTouches = 1

        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont(name: "AvenirNext-UltraLight", size: CGFloat(labelFontSize))
        label.text = "\(defaultValue)"

        stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)

        stepper.maximumValue = Double(maximumValue)
        stepper.minimumValue = Double(minimumValue)
        stepper.stepValue = 1.0
        value = defaultValue

        addSubview(stepper)
        addSubview(label)
        addGestureRecognizer(recognizer)

        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false

        addConstraint(NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: stepper, attribute: .centerX, multiplier: 1.0, constant: 1.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: label, attribute: .centerX, multiplier: 1.0, constant: 1.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: label, attribute: .top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.bottom, relatedBy: .equal, toItem: stepper, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0))
    }

    override open var intrinsicContentSize : CGSize {
        return CGSize(width: 110, height: 150)
    }

    @objc func stepperValueChanged(_ sender: UIStepper) {
        label.text = "\(Int(stepper.value))"
        sendActions(for: .valueChanged)
    }

    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        let affector = Double(-1.0 * translation.y / 8.5)
        value = Int(Double(value) - affector)
        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)
        sendActions(for: .valueChanged)
    }

}
