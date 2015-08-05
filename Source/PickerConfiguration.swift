import UIKit

public class PickerConfiguration {

  // MARK: Colors

  public var backgroundColor = UIColor(red:0.15, green:0.19, blue:0.24, alpha:1)
  public var mainColor = UIColor(red:0.09, green:0.11, blue:0.13, alpha:1)

  // MARK: Fonts

  public var numberLabelFont = UIFont(name: "HelveticaNeue-Bold", size: 19)!
  public var doneButton = UIFont(name: "HelveticaNeue-Medium", size: 19)!
  public var flashButton = UIFont(name: "HelveticaNeue-Medium", size: 12)!

  // MARK: Titles

  public var cancelButtonTitle = "Cancel"
  public var doneButtonTitle = "Done"

  // MARK: Dimensions

  public var cellSpacing: CGFloat = 2
}
