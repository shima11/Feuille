//
//  FeuilleContainerViewController.swift
//  Feuille
//
//  Created by jinsei_shima on 2019/02/21.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import Foundation

public protocol FeuilleViewDelegate: class {

  func didChangeHeight(height: CGFloat)
}

public class FeuilleView: TouchThroughView {

  public enum ItemType {
    case top, middle, bottom
  }

  // MARK: - Properties

  public let topView = ContentView()
  public let middleView = ContentView()
  public let bottomView = ContentView()

  public weak var delegate: FeuilleViewDelegate?

  private var topViewHeight: NSLayoutConstraint!
  private var middleViewHeight: NSLayoutConstraint!
  private var bottomViewHeight: NSLayoutConstraint!

  private let keyboardLayoutGuide: UILayoutGuide = .init()
  private var keyboardHeight: NSLayoutConstraint!

  private var bottomMiddleToKeyboardConstraint: NSLayoutConstraint!
  private var bottomMiddleToBottomConstraint: NSLayoutConstraint!

  private var isIncludedTopViewHeight: Bool = true

  private let panRecognizer = UIPanGestureRecognizer()

  private var keyboardFrame: CGRect {
    didSet {
      print("keyboard farme:", keyboardFrame)
    }
  }

  private let defaultFrame: CGRect


  // MARK: - Initializers

  public init() {


    defaultFrame = CGRect(
      x: 0,
      y: UIScreen.main.bounds.height,
      width: UIScreen.main.bounds.width,
      height: 0
    )

    keyboardFrame = defaultFrame

    super.init(frame: .zero)

    panRecognizer.delegate = self
    panRecognizer.addTarget(self, action: #selector(panGesture(_:)))

    keyboardLayout: do {

      addLayoutGuide(keyboardLayoutGuide)

      let height = keyboardLayoutGuide.heightAnchor.constraint(equalToConstant: 0)
      self.keyboardHeight = height

      NSLayoutConstraint.activate([
        height,
        keyboardLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor),
        keyboardLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor),
        keyboardLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

    }

    addSubview(topView)
    addSubview(middleView)
    addSubview(bottomView)

    topView: do {

      topView.translatesAutoresizingMaskIntoConstraints = false

      topViewHeight = topView.heightAnchor.constraint(equalToConstant: 0)
      topViewHeight.isActive = true

      NSLayoutConstraint.activate([
        topView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 24),
        topView.rightAnchor.constraint(equalTo: rightAnchor),
        topView.leftAnchor.constraint(equalTo: leftAnchor),
        topView.bottomAnchor.constraint(equalTo: middleView.topAnchor),
        ])

    }

    middleView: do {

      middleView.translatesAutoresizingMaskIntoConstraints = false

      middleViewHeight = middleView.heightAnchor.constraint(equalToConstant: 0)
      middleViewHeight.isActive = true

      bottomMiddleToKeyboardConstraint = middleView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
      bottomMiddleToKeyboardConstraint.priority = .defaultLow
      bottomMiddleToBottomConstraint = middleView.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
      bottomMiddleToBottomConstraint.priority = .defaultLow

      if #available(iOS 11.0, *) {

        NSLayoutConstraint.activate([
          middleView.rightAnchor.constraint(equalTo: rightAnchor),
          middleView.leftAnchor.constraint(equalTo: leftAnchor),
          bottomMiddleToKeyboardConstraint,
          bottomMiddleToBottomConstraint,
          middleView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor),
          middleView.bottomAnchor.constraint(lessThanOrEqualTo: bottomView.topAnchor),
          middleView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor)
          ])

      } else {

        NSLayoutConstraint.activate([
          middleView.rightAnchor.constraint(equalTo: rightAnchor),
          middleView.leftAnchor.constraint(equalTo: leftAnchor),
          bottomMiddleToKeyboardConstraint,
          bottomMiddleToBottomConstraint,
          middleView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor),
          middleView.bottomAnchor.constraint(lessThanOrEqualTo: bottomView.topAnchor),
          middleView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
          ])

      }

    }

    bottomView: do {

      bottomView.translatesAutoresizingMaskIntoConstraints = false

      bottomViewHeight = bottomView.heightAnchor.constraint(equalToConstant: 0)
      bottomViewHeight.isActive = true

      if #available(iOS 11.0, *) {

        NSLayoutConstraint.activate([
          bottomView.rightAnchor.constraint(equalTo: rightAnchor),
          bottomView.leftAnchor.constraint(equalTo: leftAnchor),
          bottomView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
          ])

      } else {

        NSLayoutConstraint.activate([
          bottomView.rightAnchor.constraint(equalTo: rightAnchor),
          bottomView.leftAnchor.constraint(equalTo: leftAnchor),
          bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
          ])

      }

    }

    startObserveKeyboard()

  }


  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - Functions

  public func set(topView view: UIView, animated: Bool, isIncludedTopViewHeight: Bool) {

    self.isIncludedTopViewHeight = isIncludedTopViewHeight

    topView.set(bodyView: view)

    set(constraint: topViewHeight, value: view.intrinsicContentSize.height, animated: animated)

    delegate?.didChangeHeight(height: feuilleKeyboardHeight(isIncludedTopViewHeight: isIncludedTopViewHeight))

  }

  public func set(middleView view: UIView, animated: Bool) {

    middleView.set(bodyView: view)
    set(constraint: middleViewHeight, value: view.intrinsicContentSize.height, animated: animated)

    delegate?.didChangeHeight(height: feuilleKeyboardHeight(isIncludedTopViewHeight: isIncludedTopViewHeight))

  }

  public func set(bottomView view: UIView, animated: Bool) {

    bottomView.set(bodyView: view)
    set(constraint: bottomViewHeight, value: view.intrinsicContentSize.height, animated: animated)

    delegate?.didChangeHeight(height: feuilleKeyboardHeight(isIncludedTopViewHeight: isIncludedTopViewHeight))

  }

  public func dismiss(types: [ItemType], animated: Bool) {

    if types.contains(.top) {
      set(constraint: topViewHeight, value: 0, animated: animated)
    }
    if types.contains(.middle) {
      set(constraint: middleViewHeight, value: 0, animated: animated)
    }
    if types.contains(.bottom) {
      set(constraint: bottomViewHeight, value: 0, animated: animated)
    }
    
    delegate?.didChangeHeight(height: 0)

  }

  #warning("標準のkeyboardのHeightも含めてFeuilleの管理しているKeyboardのトータルのHeightを返すプロパティがほしい")

  private func feuilleKeyboardHeight(isIncludedTopViewHeight: Bool) -> CGFloat {

    if isIncludedTopViewHeight {
      return topView.intrinsicContentSize.height + middleView.intrinsicContentSize.height + bottomView.intrinsicContentSize.height
    }
    return middleView.intrinsicContentSize.height + bottomView.intrinsicContentSize.height
  }

  private func set(
    constraint: NSLayoutConstraint,
    value: CGFloat,
    animated: Bool,
    animationDuration: TimeInterval = 0.25,
    animationOptions: UIView.AnimationOptions = .overrideInheritedCurve
    ){

    if animated {

      constraint.constant = value

      UIView.animate(
        withDuration: animationDuration,
        delay: 0,
        options: animationOptions,
        animations: {
          self.layoutIfNeeded()
      },
        completion: nil
      )

    } else {

      constraint.constant = value

    }
  }

  private func startObserveKeyboard() {

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillChangeFrame(_:)),
      name: UIResponder.keyboardWillChangeFrameNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHideFrame(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationDidFinishLaunching(_:)),
      name: UIApplication.didFinishLaunchingNotification,
      object: nil
    )

  }

  @objc
  private func applicationDidFinishLaunching(_ note: Notification) {

    UIApplication.shared.windows.first?.addGestureRecognizer(self.panRecognizer)
  }

  @objc
  private func keyboardWillChangeFrame(_ note: Notification) {

    #warning("scroll中のkeyobard dismissの対応、これだけだとドラッグ中のキーボードの高さの変化に追従できない")

    var newFrame: CGRect {
      let rectValue = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
      return rectValue?.cgRectValue ?? defaultFrame
    }

    keyboardFrame = newFrame

    var animationDuration: Double {
      if let number = note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
        return number.doubleValue
      } else {
        return 0.25
      }
    }

    var animationCurve: Int {
      if let number = note.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
        return number.intValue
      }
      return UIView.AnimationCurve.easeInOut.rawValue
    }

    if keyboardFrame.height > 0 {
        // keyboardが開くときはbottomViewを閉じる
      set(constraint: bottomViewHeight, value: 0, animated: true)
    }

    set(
      constraint: self.keyboardHeight,
      value: UIScreen.main.bounds.height - keyboardFrame.minY,
      animated: true,
      animationDuration: animationDuration,
      animationOptions: UIView.AnimationOptions(rawValue: UInt(animationCurve << 16))
    )

  }

  @objc
  private func keyboardWillHideFrame(_ note: Notification) {

    #warning("keyboardWillChangeFrameと処理を共通化したい")

    var newFrame: CGRect {
      let rectValue = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
      return rectValue?.cgRectValue ?? defaultFrame
    }

    keyboardFrame = newFrame

    var animationDuration: Double {
      if let number = note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
        return number.doubleValue
      } else {
        return 0.25
      }
    }

    var animationCurve: Int {
      if let number = note.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
        return number.intValue
      }
      return UIView.AnimationCurve.easeInOut.rawValue
    }

    set(
      constraint: self.keyboardHeight,
      value: UIScreen.main.bounds.height - keyboardFrame.minY,
      animated: true,
      animationDuration: animationDuration,
      animationOptions: UIView.AnimationOptions(rawValue: UInt(animationCurve << 16))
    )

  }

  @objc
  private func panGesture(_ recognizer: UIPanGestureRecognizer) {

    guard
      case .changed = recognizer.state,
      let window = UIApplication.shared.windows.first,
      keyboardFrame.origin.y < UIScreen.main.bounds.height
      else { return }

    let origin = recognizer.location(in: window)
    var newFrame = keyboardFrame
    newFrame.origin.y = max(origin.y, UIScreen.main.bounds.height - keyboardFrame.height)

    keyboardFrame = newFrame
  }

}

// MARK: - UIGestureRecognizerDelegate

extension FeuilleView: UIGestureRecognizerDelegate {

  public func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldReceive touch: UITouch
    ) -> Bool {

    let point = touch.location(in: gestureRecognizer.view)
    var view = gestureRecognizer.view?.hitTest(point, with: nil)

    while let candidate = view {
      if let scrollView = candidate as? UIScrollView,
        case .interactive = scrollView.keyboardDismissMode {
        return true
      }
      view = candidate.superview
    }

    return false
  }

  public func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {

    return gestureRecognizer === self.panRecognizer
  }

}
