//
//  MenuViewController.swift
//  CardsAgainst
//
//  Created by JP Simard on 10/25/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import UIKit
import Cartography

final class SessionViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: Properties

    private var startButton = UIButton()
    private var separator = UIView()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let screenFrame = UIScreen.mainScreen().bounds

        let space: CGFloat = 150.0

        view.frame = CGRect(x: screenFrame.origin.x, y: screenFrame.origin.y + space, width: screenFrame.width, height: screenFrame.height - space)
        view.layoutSubviews()
        // UI
        setupBackground()
        setupstartButton()
        setupSeparator()
        setupCollectionView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        ConnectionManager.onConnect { _ in
            self.updatePlayers()
        }
        ConnectionManager.onDisconnect { _ in
            self.updatePlayers()
        }
        ConnectionManager.onEvent(.StartSession) { _, object in
            let dict = object as [String: NSData]
        }
    }

    override func viewWillDisappear(animated: Bool) {
        ConnectionManager.onConnect(nil)
        ConnectionManager.onDisconnect(nil)
        ConnectionManager.onEvent(.StartSession, run: nil)

        super.viewWillDisappear(animated)
    }

    // MARK: UI


    func setupBackground() {

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))

        let screenFrame = UIScreen.mainScreen().applicationFrame
        blurView.frame = view.frame
        view.addSubview(blurView)
    }

    func setupstartButton() {
        // Button
        startButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        startButton.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 24)
        startButton.setTitle("Waiting For Players", forState: .Disabled)
        startButton.setTitle("Start Session", forState: .Normal)
        startButton.addTarget(self, action: "startSession", forControlEvents: .TouchUpInside)
        startButton.enabled = false
        view.addSubview(startButton)

        // Layout
        layout(startButton) { button in
            button.top == button.superview!.top + 60
            button.centerX == button.superview!.centerX
        }
    }

    func setupSeparator() {
        // Separator
        separator.setTranslatesAutoresizingMaskIntoConstraints(false)
        separator.backgroundColor = UIColor.grayColor()
        view.addSubview(separator)

        // Layout
        layout(separator, startButton) { separator, startButton in
            separator.top == startButton.bottom + 10
            separator.centerX == separator.superview!.centerX
            separator.width == separator.superview!.width - 40
            separator.height == (1 / Float(UIScreen.mainScreen().scale))
        }
    }

    func setupCollectionView() {
        // Collection View
        let cvLayout = collectionView!.collectionViewLayout as UICollectionViewFlowLayout
        cvLayout.itemSize = CGSize(width: separator.frame.size.width, height: 50)
        cvLayout.minimumLineSpacing = 0
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.backgroundColor = UIColor.clearColor()
        collectionView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView!.registerClass(PlayerCell.self,
            forCellWithReuseIdentifier: PlayerCell.reuseID)
        collectionView!.alwaysBounceVertical = true
        view.addSubview(collectionView!)

        // Layout
        layout(collectionView!, separator) { collectionView, separator in
            collectionView.top == separator.bottom
            collectionView.left == separator.left
            collectionView.right == separator.right
            collectionView.bottom == collectionView.superview!.bottom
        }
    }


    // MARK: Actions

    func startSession() {

    }


    // MARK: Multipeer


    func updatePlayers() {
        startButton.enabled = (ConnectionManager.otherPlayers.count > 0)
        collectionView!.reloadData()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ConnectionManager.otherPlayers.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PlayerCell.reuseID, forIndexPath: indexPath) as PlayerCell
        cell.label.text = ConnectionManager.otherPlayers[indexPath.row].name
        return cell
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
