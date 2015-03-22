import UIKit
import Cartography

enum SessionEvent {
    case Initiated,
         Left,
         Joined
}
protocol SessionCreationDelegate {
    func sessionViewControllerDidFinish(event: SessionEvent?)
}

final class SessionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, BackgroundViewDelegate {

    private class HideBackgroundView: UIView {
        var delegate: BackgroundViewDelegate?
        private override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
            delegate?.viewWasTapped()
        }
    }

    // MARK: Properties

    private var overlayView = HideBackgroundView()

    private var managementMode = false
    private var playersLabel = UILabel()
    private var actionButton = UIButton()
    private var instructionLabel = UILabel()
    private var separator = UIView()
    private var collectionView = UICollectionView(frame: CGRectZero,
        collectionViewLayout: UICollectionViewFlowLayout())
    var delegate: SessionCreationDelegate?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if !ConnectionManager.inSession {
            ConnectionManager.start()
            
        }
        if !ConnectionManager.aloneInSession {
            managementMode = true
        }
        
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

        ConnectionManager.onConnect { peerID in
            println("Connected: \(peerID)")
            self.updatePlayers()
        }
        ConnectionManager.onDisconnect { peerID in
            println("Disconnected: \(peerID)")
            self.updatePlayers()
            if ConnectionManager.aloneInSession {
                println("Session is empty")
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        ConnectionManager.onConnect(nil)
        ConnectionManager.onDisconnect(nil)

        super.viewWillDisappear(animated)
    }

    // MARK: UI

    func viewWasTapped() {
        delegate?.sessionViewControllerDidFinish(nil)
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
        playersLabel.font = UIFont(name: "AvenirNext-Medium", size: 15)
        playersLabel.textColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        playersLabel.text = "Players"
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
        instructionLabel.numberOfLines = 2
        instructionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        instructionLabel.textAlignment = .Center

        view.addSubview(instructionLabel)
        
        layout(instructionLabel){ label in
            label.centerY == label.superview!.centerY
            label.centerX == label.superview!.centerX
            label.width == label.superview!.width - 50
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
            separator.width == separator.superview!.width - 30
            separator.height == (1 / Float(UIScreen.mainScreen().scale))
        }
    }

    func setupCollectionView() {
        // Collection View
        let cvLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
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

        actionButton.enabled = false

        actionButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        actionButton.setTitle("Waiting for Players", forState: .Disabled)
        actionButton.setTitle("Begin Session", forState: .Normal)
        if managementMode {
            actionButton.setTitle("Leave Session", forState: .Normal)
            actionButton.enabled = true
        }
        actionButton.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Normal)
        actionButton.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.25), forState: .Disabled)
        actionButton.titleLabel!.font = UIFont(name: "AvenirNext-Regular", size: 15)
        actionButton.titleLabel!.textAlignment = .Center
        actionButton.addTarget(self, action: "actionButtonTapped", forControlEvents: .TouchUpInside)

        view.addSubview(actionButton)
        layout(actionButton) {
            button in
            button.bottom == button.superview!.bottom - 15
            button.centerX == button.superview!.centerX
        }
    }

    // MARK: Actions

    func actionButtonTapped() {
        if managementMode {
            delegate?.sessionViewControllerDidFinish(.Left)
        }
        else {
            delegate?.sessionViewControllerDidFinish(.Initiated)
        }
    }

    // MARK: Multipeer

    func updatePlayers() {
        if ConnectionManager.aloneInSession {
            //ConnectionManager.stop()
            //ConnectionManager.start()
            managementMode = false
        }
        collectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = ConnectionManager.otherPlayers.count
        if count > 0 {
            instructionLabel.hidden = true
            actionButton.enabled = true
        } else {
            instructionLabel.hidden = false
            actionButton.enabled = false
        }
        return ConnectionManager.otherPlayers.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PlayerCell.reuseID, forIndexPath: indexPath) as! PlayerCell
        cell.label.text = ConnectionManager.otherPlayers[indexPath.row].name
        return cell
    }

    //MARK: Animation

    func animateIn() {
        let controlAreaHeight: CGFloat = view.frame.height
        view.userInteractionEnabled = true

        overlayView.backgroundColor = UIColor(white: 0, alpha: 0.2)
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
        view.superview!.insertSubview(overlayView, aboveSubview: view.superview!.subviews[index] as! UIView)
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
        
    }
}
