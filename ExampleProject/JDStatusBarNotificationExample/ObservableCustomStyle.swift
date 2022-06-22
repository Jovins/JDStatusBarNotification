//
//

import Combine

class CustomTextStyle: ObservableObject, Equatable {
  @Published var font: UIFont
  @Published var textColor: UIColor?
  @Published var textOffsetY: Double
  @Published var textShadowColor: UIColor?
  @Published var textShadowOffset: CGSize

  init(_ textStyle: NotificationTextStyle) {
    font = textStyle.font
    textColor = textStyle.textColor
    textOffsetY = textStyle.textOffsetY
    textShadowColor = textStyle.textShadowColor
    textShadowOffset = textStyle.textShadowOffset
  }

  static func == (lhs: CustomTextStyle, rhs: CustomTextStyle) -> Bool {
    return false // a hack to trigger .onChange(of: style) on every change
  }

  func computedStyle() -> NotificationTextStyle {
    let style = NotificationTextStyle()
    style.textColor = textColor
    style.font = font
    style.textOffsetY = textOffsetY
    style.textShadowColor = textShadowColor
    style.textShadowOffset = textShadowOffset
    return style
  }

  @SimpleStringBuilder
  func styleConfigurationString(propertyName: String) -> String {
    """
    style.\(propertyName).textColor = \(textColor?.readableRGBAColorString ?? "nil")
    style.\(propertyName).font = UIFont(name: \"\(font.familyName)\", size: \(font.pointSize))!
    style.\(propertyName).textOffsetY = \(textOffsetY)
    """

    if let textShadowColor = textShadowColor {
      """
      style.\(propertyName).textShadowColor = \(textShadowColor.readableRGBAColorString)
      style.\(propertyName).textShadowOffset = CGSize(width: \(textShadowOffset.width), height: \(textShadowOffset.height))
      """
    }
  }
}

class ObservableCustomStyle: ObservableObject, Equatable {
  @Published var textStyle: CustomTextStyle
  @Published var subtitleStyle: CustomTextStyle

  @Published var backgroundColor: UIColor?
  @Published var backgroundType: BarBackgroundType

  @Published var minimumPillWidth: Double
  @Published var pillHeight: Double
  @Published var pillSpacingY: Double
  @Published var pillBorderColor: UIColor?
  @Published var pillBorderWidth: Double
  @Published var pillShadowColor: UIColor?
  @Published var pillShadowRadius: Double
  @Published var pillShadowOffset: CGSize

  @Published var animationType: BarAnimationType
  @Published var systemStatusBarStyle: StatusBarSystemStyle
  @Published var canSwipeToDismiss: Bool
  @Published var canDismissDuringUserInteraction: Bool

  @Published var leftViewSpacing: Double
  @Published var leftViewOffset: CGSize
  @Published var leftViewAlignment: BarLeftViewAlignment

  @Published var pbBarColor: UIColor?
  @Published var pbBarHeight: Double
  @Published var pbPosition: ProgressBarPosition
  @Published var pbHorizontalInsets: Double
  @Published var pbCornerRadius: Double
  @Published var pbBarOffset: Double

  init(_ defaultStyle: StatusBarStyle) {
    // text
    textStyle = CustomTextStyle(defaultStyle.textStyle)
    subtitleStyle = CustomTextStyle(defaultStyle.subtitleStyle)

    // background
    backgroundColor = defaultStyle.backgroundStyle.backgroundColor
    backgroundType = defaultStyle.backgroundStyle.backgroundType
    minimumPillWidth = defaultStyle.backgroundStyle.pillStyle.minimumWidth

    // pill
    pillHeight = defaultStyle.backgroundStyle.pillStyle.height
    pillSpacingY = defaultStyle.backgroundStyle.pillStyle.topSpacing
    pillBorderColor = defaultStyle.backgroundStyle.pillStyle.borderColor
    pillBorderWidth = defaultStyle.backgroundStyle.pillStyle.borderWidth
    pillShadowColor = defaultStyle.backgroundStyle.pillStyle.shadowColor
    pillShadowRadius = defaultStyle.backgroundStyle.pillStyle.shadowRadius
    pillShadowOffset = defaultStyle.backgroundStyle.pillStyle.shadowOffset

    // bar
    animationType = .bounce
    systemStatusBarStyle = .darkContent
    canSwipeToDismiss = defaultStyle.canSwipeToDismiss
    canDismissDuringUserInteraction = defaultStyle.canDismissDuringUserInteraction

    // left view
    leftViewSpacing = defaultStyle.leftViewStyle.spacing
    leftViewOffset = defaultStyle.leftViewStyle.offset
    leftViewAlignment = defaultStyle.leftViewStyle.alignment

    // progress bar
    pbBarColor = defaultStyle.progressBarStyle.barColor
    pbBarHeight = defaultStyle.progressBarStyle.barHeight
    pbPosition = defaultStyle.progressBarStyle.position
    pbHorizontalInsets = defaultStyle.progressBarStyle.horizontalInsets
    pbCornerRadius = defaultStyle.progressBarStyle.cornerRadius
    pbBarOffset = defaultStyle.progressBarStyle.offsetY
  }

  static func == (lhs: ObservableCustomStyle, rhs: ObservableCustomStyle) -> Bool {
    return false // a hack to trigger .onChange(of: style) on every change
  }

  func registerComputedStyle() -> String {
    let styleName = "custom"
    NotificationPresenter.shared().addStyle(styleName: styleName) { _ in
      computedStyle()
    }
    return styleName
  }

  func computedStyle() -> StatusBarStyle {
    let style = StatusBarStyle()

    style.textStyle = textStyle.computedStyle()
    style.subtitleStyle = subtitleStyle.computedStyle()

    style.backgroundStyle.backgroundColor = backgroundColor
    style.backgroundStyle.backgroundType = backgroundType
    style.backgroundStyle.pillStyle.minimumWidth = minimumPillWidth
    style.backgroundStyle.pillStyle.height = pillHeight
    style.backgroundStyle.pillStyle.topSpacing = pillSpacingY
    style.backgroundStyle.pillStyle.borderColor = pillBorderColor
    style.backgroundStyle.pillStyle.borderWidth = pillBorderWidth
    style.backgroundStyle.pillStyle.shadowColor = pillShadowColor
    style.backgroundStyle.pillStyle.shadowRadius = pillShadowRadius
    style.backgroundStyle.pillStyle.shadowOffset = pillShadowOffset

    style.animationType = animationType
    style.systemStatusBarStyle = systemStatusBarStyle
    style.canSwipeToDismiss = canSwipeToDismiss
    style.canDismissDuringUserInteraction = canDismissDuringUserInteraction

    style.leftViewStyle.spacing = leftViewSpacing
    style.leftViewStyle.offset = leftViewOffset
    style.leftViewStyle.alignment = leftViewAlignment

    style.progressBarStyle.barColor = pbBarColor
    style.progressBarStyle.barHeight = pbBarHeight
    style.progressBarStyle.position = pbPosition
    style.progressBarStyle.horizontalInsets = pbHorizontalInsets
    style.progressBarStyle.cornerRadius = pbCornerRadius
    style.progressBarStyle.offsetY = pbBarOffset

    return style
  }

  @SimpleStringBuilder
  func styleConfigurationString() -> String {
    textStyle.styleConfigurationString(propertyName: "textStyle")
    ""
    subtitleStyle.styleConfigurationString(propertyName: "subtitleStyle")

    """
    \nstyle.backgroundStyle.backgroundColor = \(backgroundColor?.readableRGBAColorString ?? "nil")
    style.backgroundStyle.backgroundType = \(backgroundType.stringValue)
    """

    if backgroundType == .pill {
      """
      \nstyle.backgroundStyle.pillStyle.minimumWidth = \(minimumPillWidth)
      style.backgroundStyle.pillStyle.height = \(pillHeight)
      style.backgroundStyle.pillStyle.topSpacing = \(pillSpacingY)
      """

      if let pillBorderColor = pillBorderColor {
        """
        style.backgroundStyle.pillStyle.borderColor = \(pillBorderColor.readableRGBAColorString)
        style.backgroundStyle.pillStyle.borderWidth = \(pillBorderWidth)
        """
      }

      if let pillShadowColor = pillShadowColor {
        """
        style.backgroundStyle.pillStyle.shadowColor = \(pillShadowColor.readableRGBAColorString)
        style.backgroundStyle.pillStyle.shadowRadius = \(pillShadowRadius)
        style.backgroundStyle.pillStyle.shadowOffset = CGSize(width: \(pillShadowOffset.width), height: \(pillShadowOffset.height))
        """
      }
    }

    """
    \nstyle.animationType = \(animationType.stringValue)
    style.systemStatusBarStyle = \(systemStatusBarStyle.stringValue)
    style.canSwipeToDismiss = \(canSwipeToDismiss)
    style.canDismissDuringUserInteraction = \(canDismissDuringUserInteraction)

    style.leftViewStyle.spacing = \(leftViewSpacing)
    style.leftViewStyle.offset = CGSize(width: \(leftViewOffset.width), height: \(leftViewOffset.height))
    style.leftViewStyle.alignment = \(leftViewAlignment.stringValue)

    style.progressBarStyle.barHeight = \(pbBarHeight)
    style.progressBarStyle.position = \(pbPosition.stringValue)
    style.progressBarStyle.barColor = \(pbBarColor?.readableRGBAColorString ?? "nil")
    style.progressBarStyle.horizontalInsets = \(pbHorizontalInsets)
    style.progressBarStyle.cornerRadius = \(pbCornerRadius)
    style.progressBarStyle.offsetY = \(pbBarOffset)
    """
  }
}

@resultBuilder
enum SimpleStringBuilder {
  static func buildBlock(_ parts: String?...) -> String {
    parts.compactMap { $0 }.joined(separator: "\n")
  }

  static func buildOptional(_ component: String?) -> String? {
    return component
  }
}

extension UIColor {
  var readableRGBAColorString: String {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    if #available(iOS 14.0, *) {
      return "UIColor(red: \(red), green: \(green), blue: \(blue), alpha: \(alpha)) // \"\(self.accessibilityName)\""
    } else {
      return "??"
    }
  }
}
