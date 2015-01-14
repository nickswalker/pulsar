//
//  PlayerCell.swift
//  CardsAgainst
//
//  Created by JP Simard on 11/4/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

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

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLabel() {
        // Label
        label.font = UIFont(name: "AvenirNext-Regular", size: 18)
        label.textAlignment = .Center
        contentView.addSubview(label)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.textColor = UIColor.blackColor().colorWithAlphaComponent(0.5)

        // Layout
        layout(label) { label in
            label.edges == inset(label.superview!.edges, 15, 10); return
        }
    }
}
