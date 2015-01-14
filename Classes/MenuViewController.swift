//
//  MenuViewController.swift
//  CardsAgainst
//
//  Created by JP Simard on 10/25/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import UIKit
import Cartography

final class MenuViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: Properties

    private var startGameButton = UIButton.buttonWithType(.System) as UIButton
    private var separator = UIView()
    private var collectionView = UICollectionView(frame: CGRectZero,
        collectionViewLayout: UICollectionViewFlowLayout())

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        setupNavigationBar()
        setupLaunchImage()
        setupStartGameButton()
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

    func setupNavigationBar() {
        navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController!.navigationBar.shadowImage = UIImage()
        navigationController!.navigationBar.translucent = true
    }

    func setupLaunchImage() {

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        blurView.frame = view.bounds
        view.addSubview(blurView)
    }

    func setupStartGameButton() {
        // Button
        startGameButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        startGameButton.titleLabel!.font = startGameButton.titleLabel!.font.fontWithSize(25)
        startGameButton.setTitle("Waiting For Players", forState: .Disabled)
        startGameButton.setTitle("Start Game", forState: .Normal)
        startGameButton.addTarget(self, action: "startGame", forControlEvents: .TouchUpInside)
        startGameButton.enabled = false
        view.addSubview(startGameButton)

        // Layout
        layout(startGameButton) { button in
            button.top == button.superview!.top + 60
            button.centerX == button.superview!.centerX
        }
    }

    func setupSeparator() {
        // Separator
        separator.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(separator)

        // Layout
        layout(separator, startGameButton) { separator, startGameButton in
            separator.top == startGameButton.bottom + 10
            separator.centerX == separator.superview!.centerX
            separator.width == separator.superview!.width - 40
            separator.height == (1 / Float(UIScreen.mainScreen().scale))
        }
    }

    func setupCollectionView() {
        // Collection View
        let cvLayout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
        cvLayout.itemSize = CGSizeMake(separator.frame.size.width, 50)
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

    func startGame() {

    }

    // MARK: Multipeer

    func updatePlayers() {
        startGameButton.enabled = (ConnectionManager.otherPlayers.count > 0)
        collectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ConnectionManager.otherPlayers.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PlayerCell.reuseID, forIndexPath: indexPath) as PlayerCell
        cell.label.text = ConnectionManager.otherPlayers[indexPath.row].name
        return cell
    }
}
