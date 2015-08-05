import UIKit

public class ImagePickerController: UIViewController {

  struct Dimensions {
    static let bottomContainerHeight: CGFloat = 108
  }

  lazy var galleryView: ImageGalleryView = { [unowned self] in
    let galleryView = ImageGalleryView()
    galleryView.backgroundColor = self.configuration.backgroundColor
    galleryView.setTranslatesAutoresizingMaskIntoConstraints(false)
    galleryView.delegate = self

    return galleryView
    }()

  lazy var bottomContainer: BottomContainerView = {
    let view = BottomContainerView()
    view.backgroundColor = UIColor(red:0.09, green:0.11, blue:0.13, alpha:1)
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.delegate = self

    return view
    }()

  lazy var topView: TopView = {
    let view = TopView()
    view.backgroundColor = UIColor(red:0.09, green:0.11, blue:0.13, alpha:1)
    view.setTranslatesAutoresizingMaskIntoConstraints(false)

    return view
    }()

  lazy var configuration: PickerConfiguration = {
    let configuration = PickerConfiguration()
    return configuration
    }()

  lazy var cameraController: CameraView = {
    let controller = CameraView()
    return controller
    }()

  var topSeparatorCenter: CGPoint!
  var initialFrame: CGRect!

  public var doneButtonTitle: String? {
    didSet {
      bottomContainer.doneButton.setTitle(doneButtonTitle!, forState: .Normal)
    }
  }

  // MARK: - View lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()
    
    [topView, cameraController.view, galleryView, bottomContainer].map { self.view.addSubview($0) }

    setupConstraints()
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.sharedApplication().statusBarHidden = true
  }

  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    galleryView.frame = CGRectMake(0,
      UIScreen.mainScreen().bounds.height - bottomContainer.frame.height - ImageGalleryView.Dimensions.galleryHeight,
      UIScreen.mainScreen().bounds.width,
      ImageGalleryView.Dimensions.galleryHeight)
    galleryView.updateFrames()
    cameraController.view.frame = CGRectMake(0, 32,
      UIScreen.mainScreen().bounds.width, galleryView.frame.origin.y - 32)
  }

  // MARK: - Autolayout

  func setupConstraints() {
    let attributes: [NSLayoutAttribute] = [.Bottom, .Right, .Width]
    let topViewAttributes: [NSLayoutAttribute] = [.Left, .Top, .Width]

    attributes.map {
      self.view.addConstraint(NSLayoutConstraint(item: self.bottomContainer, attribute: $0,
        relatedBy: .Equal, toItem: self.view, attribute: $0,
        multiplier: 1, constant: 0))
    }

    view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: Dimensions.bottomContainerHeight))

    topViewAttributes.map {
      self.view.addConstraint(NSLayoutConstraint(item: self.topView, attribute: $0,
        relatedBy: .Equal, toItem: self.view, attribute: $0,
        multiplier: 1, constant: 0))
    }

    view.addConstraint(NSLayoutConstraint(item: topView, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: TopView.Dimensions.height))
  }

  // MARK: - Helpers

  public override func prefersStatusBarHidden() -> Bool {
    return true
  }
}

// MARK: - Action methods

extension ImagePickerController: BottomContainerViewDelegate {

  func pickerButtonDidPress() { }

  func doneButtonDidPress() { }

  func cancelButtonDidPress() {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func imageWrapperDidPress() { }
}

// MARK: - Pan gesture handler

extension ImagePickerController: ImageGalleryPanGestureDelegate {

  func panGestureDidStart() {
    topSeparatorCenter = galleryView.topSeparator.center
    initialFrame = galleryView.frame
  }

  func panGestureDidChange(translation: CGPoint, location: CGPoint, velocity: CGPoint) {
    galleryView.frame.size.height = initialFrame.height - translation.y
    galleryView.frame.origin.y = initialFrame.origin.y + translation.y
    galleryView.topSeparator.frame.origin.y = 0

    if galleryView.frame.size.height - galleryView.topSeparator.frame.height > 100 {
      galleryView.collectionViewLayout.invalidateLayout()
      galleryView.collectionView.frame.size.height = galleryView.frame.size.height - galleryView.topSeparator.frame.height
      galleryView.collectionSize = CGSizeMake(galleryView.frame.size.height - galleryView.topSeparator.frame.height, galleryView.frame.size.height - galleryView.topSeparator.frame.height)
      galleryView.collectionView.reloadData()
    } else {
      galleryView.collectionView.frame.origin.y = galleryView.topSeparator.frame.height
    }

    if location.y >= initialFrame.origin.y + initialFrame.height - galleryView.topSeparator.frame.height {
      galleryView.frame.size.height = galleryView.topSeparator.frame.height
      galleryView.frame.origin.y = initialFrame.origin.y + initialFrame.height - galleryView.topSeparator.frame.height
    } else if galleryView.collectionView.frame.height >= ImageGalleryView.Dimensions.galleryHeight {
      galleryView.frame.size.height = ImageGalleryView.Dimensions.galleryHeight + galleryView.topSeparator.frame.height
      galleryView.frame.origin.y = initialFrame.origin.y + initialFrame.height - galleryView.topSeparator.frame.height - ImageGalleryView.Dimensions.galleryHeight
      galleryView.collectionView.frame.size.height = ImageGalleryView.Dimensions.galleryHeight
      galleryView.collectionSize = CGSizeMake(galleryView.collectionView.frame.height, galleryView.collectionView.frame.height)
      galleryView.collectionView.reloadData()
    }

    cameraController.view.frame.size.height = galleryView.frame.origin.y - topView.frame.height
    cameraController.view.frame.origin.y = topView.frame.height
  }

  func panGestureDidEnd(translation: CGPoint, location: CGPoint, velocity: CGPoint) {
    if velocity.y < -100 {
      UIView.animateWithDuration(0.2, animations: { [unowned self] in
        self.galleryView.frame.size.height = ImageGalleryView.Dimensions.galleryHeight + self.galleryView.topSeparator.frame.height
        self.galleryView.frame.origin.y = self.initialFrame.origin.y + self.initialFrame.height - self.galleryView.topSeparator.frame.height - ImageGalleryView.Dimensions.galleryHeight
        self.galleryView.collectionViewLayout.invalidateLayout()
        self.galleryView.collectionView.frame.size.height = ImageGalleryView.Dimensions.galleryHeight
        self.galleryView.collectionSize = CGSizeMake(self.galleryView.collectionView.frame.height, self.galleryView.collectionView.frame.height)
        self.cameraController.view.frame.size.height = self.galleryView.frame.origin.y - self.topView.frame.height
        self.cameraController.view.frame.origin.y = self.topView.frame.height
        }, completion: { finished in
          self.galleryView.collectionView.reloadData()
      })
    } else if velocity.y > 100 || galleryView.frame.size.height - galleryView.topSeparator.frame.height < 100 {
      UIView.animateWithDuration(0.2, animations: { [unowned self] in
        self.galleryView.frame.size.height = self.galleryView.topSeparator.frame.height
        self.galleryView.frame.origin.y = self.initialFrame.origin.y + self.initialFrame.height - self.galleryView.topSeparator.frame.height
        self.galleryView.collectionViewLayout.invalidateLayout()
        self.galleryView.collectionView.frame.size.height = 100
        self.galleryView.collectionSize = CGSizeMake(self.galleryView.collectionView.frame.height, self.galleryView.collectionView.frame.height)
        self.cameraController.view.frame.size.height = self.galleryView.frame.origin.y - self.topView.frame.height
        self.cameraController.view.frame.origin.y = self.topView.frame.height
        }, completion: { finished in
          self.galleryView.collectionView.reloadData()
      })
    }

  }
}
