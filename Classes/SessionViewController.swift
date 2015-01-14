//
//  MenuViewController.swift
//  CardsAgainst
//
//  Created by JP Simard on 10/25/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import UIKit
import Cartography

protocol SessionCreationDelegate {
    func sessionCreated()
    func sessionViewControllerDidFinish()
}

final class SessionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, BackgroundViewDelegate {

    private class HideBackgroundView: UIView {
        var delegate: BackgroundViewDelegate?
        override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
            delegate?.viewWasTapped()
        }
    }

    // MARK: Properties

    private var overlayView = HideBackgroundView()

    private var playersLabel = UILabel()
    private var instructionLabel = UILabel()
    private var separator = UIView()
    private var collectionView = UICollectionView(frame: CGRectZero,
        collectionViewLayout: UICollectionViewFlowLayout())
    var delegate: SessionCreationDelegate?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        ConnectionManager.start()
        let screenFrame = UIScreen.mainScreen().bounds

        let space: CGFloat = 150.0

        view.frame = CGRect(x: screenFrame.origin.x, y: screenFrame.origin.y + space, width: screenFrame.width, height: screenFrame.height - space)

        // UI
        setupBackground()
        setupPlayersLabel()
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
            self.delegate?.sessionCreated()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        ConnectionManager.onConnect(nil)
        ConnectionManager.onDisconnect(nil)
        ConnectionManager.onEvent(.StartSession, run: nil)

        super.viewWillDisappear(animated)
    }

    // MARK: UI

    func viewWasTapped() {
        animateOut()
    }

    func setupBackground() {

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        blurView.frame = view.frame
        blurView.frame.origin = CGPoint(x: 0, y: 0)

        view.addSubview(blurView)
        view.sendSubviewToBack(blurView)
    }

    func setupPlayersLabel() {
        // Button
        playersLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        playersLabel.font = UIFont(name: "AvenirNext-Medium", size: 17)
        playersLabel.textColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        playersLabel.text = "Waiting For Players"
        view.addSubview(playersLabel)

        // Layout
        layout(playersLabel) { label in
            label.top == label.superview!.top + 14
            label.centerX == label.superview!.centerX
        }

        instructionLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        instructionLabel.font = UIFont(name: "AvenirNext-Regular", size: 15)
        instructionLabel.textColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        instructionLabel.text = "Have your friends open the session pane to begin"
        instructionLabel.textAlignment = .Center

        view.addSubview(instructionLabel)
        
        layout(instructionLabel){ label in
            label.centerY == label.superview!.centerY
            label.centerX == label.superview!.centerX
        }
    }

    func setupSeparator() {
        // Separator
        separator.setTranslatesAutoresizingMaskIntoConstraints(false)
        separator.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.25)
        view.addSubview(separator)

        // Layout
        layout(separator, playersLabel) { separator, playersLabel in
            separator.top == playersLabel.bottom + 10
            separator.centerX == separator.superview!.centerX
            separator.width == separator.superview!.width - 40
            separator.height == (1 / Float(UIScreen.mainScreen().scale))
        }
    }

    func setupCollectionView() {
        // Collection View
        let cvLayout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
        cvLayout.itemSize = CGSize(width: separator.frame.size.width, height: 50)
        cvLayout.minimumLineSpacing = 0
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView.registerClass(PlayerCell.self,
            forCellWithReuseIdentifier: PlayerCell.reuseID)
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)

        // Layout
        layout(collectionView, separator) { collectionView, separator in
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
        playersLabel.enabled = (ConnectionManager.otherPlayers.count > 0)
        collectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = ConnectionManager.otherPlayers.count
        if count > 0 {
            playersLabel.text = "Players"
            instructionLabel.hidden = true
        } else {
            playersLabel.text = "Waiting for Players"
            instructionLabel.hidden = false
        }
        return ConnectionManager.otherPlayers.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PlayerCell.reuseID, forIndexPath: indexPath) as PlayerCell
        cell.label.text = ConnectionManager.otherPlayers[indexPath.row].name
        return cell
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    //MARK: Animation

    func animateIn() {
        let controlAreaHeight: CGFloat = view.frame.height
        view.userInteractionEnabled = true

        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        overlayView.frame = UIScreen.mainScreen().bounds
        overlayView.alpha = 0
        overlayView.delegate = self

        let deviceHeight: CGFloat = UIScreen.mainScreen().bounds.height
        let deviceWidth: CGFloat = UIScreen.mainScreen().bounds.width
        let scale = UIScreen.mainScreen().scale

        let offscreenFrame = CGRect(x: 0, y: deviceHeight, width: deviceWidth, height: controlAreaHeight)
        let onscreenFrame = CGRect(x: 0, y: deviceHeight - controlAreaHeight, width: deviceWidth, height: controlAreaHeight)

        view.frame = offscreenFrame

        //Insert right beneath the controls panel
        let index = view.superview!.subviews.count - 2
        view.superview!.insertSubview(overlayView, aboveSubview: view.superview!.subviews[index] as UIView)
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.overlayView.alpha = 1
            }, completion: nil)

        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.view.frame = onscreenFrame
            }, completion: nil)

    }

    func animateOut() {
        let controlAreaHeight: CGFloat = view.frame.height
        let deviceHeight: CGFloat = UIScreen.mainScreen().bounds.height
        let deviceWidth: CGFloat = UIScreen.mainScreen().bounds.width

        let offscreenFrame = CGRect(x: 0, y: deviceHeight, width: deviceWidth, height: controlAreaHeight)
        let onscreenFrame = CGRect(x: 0, y: deviceHeight - controlAreaHeight, width: deviceWidth, height: controlAreaHeight)

        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.overlayView.alpha = 0
            }, completion: { succeeded in self.overlayView.removeFromSuperview() })


        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut, animations: {
            self.view.frame = offscreenFrame
            }, completion: {
                succeeeded in self.view.removeFromSuperview()
                self.view.userInteractionEnabled = false
        })
        if delegate != nil {
            delegate!.sessionViewControllerDidFinish()
        }
        
    }
}
