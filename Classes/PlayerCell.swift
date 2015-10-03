import UIKit
import Cartography

class PlayerCell: UICollectionViewCell {

    class var reuseID: String { return "PlayerCell" }
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Label
        setupLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabel() {
        // Label
        label.font = UIFont(name: "AvenirNext-Regular", size: 18)
        label.textAlignment = .Center
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.blackColor().colorWithAlphaComponent(0.5)

        // Layout
        constrain(label) { label in
            label.edges == inset(label.superview!.edges, 15, 10); return
        }
    }
}
