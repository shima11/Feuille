//
//  FeuilleContainerViewController.swift
//  Feuille
//
//  Created by jinsei_shima on 2019/02/21.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import Foundation

#warning("bottomView → keyboard animation")
#warning("Correspondence when the height of ContentView changes.")

public protocol FeuilleViewDelegate: class {

  // height of keyboard or bottomview
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

  private let keyboardLayoutGuide: UILayoutGuide = .init()
  private var keyboardHeight: NSLayoutConstraint!

  private var topViewHeight: NSLayoutConstraint!
  private var middleViewHeight: NSLayoutConstraint!
  private var bottomViewHeight: NSLayoutConstraint!

  private var bottomMiddleToKeyboardConstraint: NSLayoutConstraint!
  private var bottomMiddleToBottomConstraint: NSLayoutConstraint!
  private var bottomViewBottomConstraint: NSLayoutConstraint!

  private var isIncludedTopViewHeight: Bool = true

  private let panRecognizer = UIPanGestureRecognizer()

  private var keyboardFrame: CGRect
  private let defaultKeyboardFrame: CGRect

//  private var keyboardWindow: UIWindow? = nil

  // MARK: - Initializers

  public init() {

    defaultKeyboardFrame = CGRect(
      x: 0,
      y: UIScreen.main.bounds.height,
      width: UIScreen.main.bounds.width,
      height: 0
    )

    keyboardFrame = defaultKeyboardFrame

    super.init(frame: .zero)

    panRecognizer.delegate = self
    panRecognizer.addTarget(self, action: #selector(panGesture(_:)))
    UIApplication.shared.windows.first?.addGestureRecognizer(self.panRecognizer)

    addSubview(topView)
    addSubview(middleView)
    addSubview(bottomView)

    startObserveKeyboard()

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

    topView: do {

      topView.translatesAutoresizingMaskIntoConstraints = false

      topViewHeight = topView.heightAnchor.constraint(equalToConstant: 0)

      NSLayoutConstraint.activate([
        topViewHeight,
        topView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 0),
        topView.rightAnchor.constraint(equalTo: rightAnchor),
        topView.leftAnchor.constraint(equalTo: leftAnchor),
        topView.bottomAnchor.constraint(equalTo: middleView.topAnchor),
        ])

    }

    middleView: do {

      middleView.translatesAutoresizingMaskIntoConstraints = false

      middleViewHeight = middleView.heightAnchor.constraint(equalToConstant: 0)

      bottomMiddleToKeyboardConstraint = middleView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
      bottomMiddleToKeyboardConstraint.priority = .defaultLow
      bottomMiddleToBottomConstraint = middleView.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
      bottomMiddleToBottomConstraint.priority = .defaultLow

      if #available(iOS 11.0, *) {

        NSLayoutConstraint.activate([
          middleViewHeight,
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

      bottomViewBottomConstraint = bottomView.bottomAnchor.constraint(equalTo: bottomAnchor)

      NSLayoutConstraint.activate([
        bottomViewHeight,
        bottomView.rightAnchor.constraint(equalTo: rightAnchor),
        bottomView.leftAnchor.constraint(equalTo: leftAnchor),
        bottomViewBottomConstraint
        ])

    }

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

    if keyboardHeight.constant > 0 {
      // If there is a keyboard, no animation.
      dismissKeyboard(animated: false, force: true)
      set(constraint: bottomViewHeight, value: view.intrinsicContentSize.height, animated: false)
      set(constraint: bottomViewBottomConstraint, value: 0, animated: false)
    } else {
      set(constraint: bottomViewHeight, value: view.intrinsicContentSize.height, animated: animated)
      set(constraint: bottomViewBottomConstraint, value: 0, animated: animated)
    }

    delegate?.didChangeHeight(height: feuilleKeyboardHeight(isIncludedTopViewHeight: isIncludedTopViewHeight))

  }

  public func dismiss(type: ItemType, animated: Bool) {

    switch type {
    case .top:
      set(constraint: topViewHeight, value: 0, animated: animated)
      delegate?.didChangeHeight(height: middleView.intrinsicContentSize.height + bottomView.intrinsicContentSize.height)
    case .middle:
      set(constraint: middleViewHeight, value: 0, animated: animated)
      delegate?.didChangeHeight(height: bottomView.intrinsicContentSize.height)
    case .bottom:
      set(constraint: bottomViewBottomConstraint, value: bottomView.intrinsicContentSize.height, animated: animated)
      delegate?.didChangeHeight(height: middleView.intrinsicContentSize.height)
    }

  }

  public func dismissKeyboard(animated: Bool, force: Bool) {

    if animated {
      self.endEditing(force)
    } else {
      UIView.setAnimationsEnabled(false)
      self.endEditing(force)
      UIView.setAnimationsEnabled(true)
    }
  }

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
    animationOptions: UIView.AnimationOptions = [.beginFromCurrentState]
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
      selector: #selector(keyboardWillShowNotification(_:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardDidShowNotification(_:)),
      name: UIResponder.keyboardDidShowNotification,
      object: nil
    )

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
  private func keyboardWillShowNotification(_ note: Notification) {

//    keyboardWindow = UIApplication.shared.windows
//      .filter { window in
//        guard let name = NSClassFromString("UIRemoteKeyboardWindow") else { return false }
//        return window.isKind(of: name)
//      }
//      .first
//    guard let window = keyboardWindow else { return }
//    window.layer.speed = 0

  }

  @objc
  private func keyboardDidShowNotification(_ note: Notification) {

//    guard let window = keyboardWindow else { return }
//    window.layer.speed = 1

//    keyboardWindow = nil
  }

  @objc
  private func applicationDidFinishLaunching(_ note: Notification) {

    UIApplication.shared.windows.first?.addGestureRecognizer(self.panRecognizer)
  }

  @objc
  private func keyboardWillChangeFrame(_ note: Notification) {

    let result = calcurateKeyboardContext(note: note)

    keyboardFrame = result.frame

    if keyboardFrame.height > 0 {
//       keyboardが開くときはbottomViewを閉じる
      set(constraint: bottomViewBottomConstraint, value: bottomView.intrinsicContentSize.height, animated: false)
    }

    set(
      constraint: keyboardHeight,
      value: UIScreen.main.bounds.height - keyboardFrame.minY,
      animated: true,
      animationDuration: result.duration,
      animationOptions: [result.curve, .beginFromCurrentState]
    )

    delegate?.didChangeHeight(height: UIScreen.main.bounds.height - keyboardFrame.minY)
  }

  @objc
  private func keyboardWillHideFrame(_ note: Notification) {

    let result = calcurateKeyboardContext(note: note)

    keyboardFrame = result.frame

    set(
      constraint: self.keyboardHeight,
      value: UIScreen.main.bounds.height - keyboardFrame.minY,
      animated: true,
      animationDuration: result.duration,
      animationOptions: [result.curve, .beginFromCurrentState]
    )

    delegate?.didChangeHeight(height: UIScreen.main.bounds.height - keyboardFrame.minY + middleView.intrinsicContentSize.height)
  }

  private func calcurateKeyboardContext(note: Notification) -> (frame: CGRect, duration: Double, curve: UIView.AnimationOptions) {

    var newFrame: CGRect {
      let rectValue = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
      return rectValue?.cgRectValue ?? defaultKeyboardFrame
    }

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

    return (newFrame, animationDuration, UIView.AnimationOptions(rawValue: UInt(animationCurve << 16)))
  }

  @objc
  private func panGesture(_ recognizer: UIPanGestureRecognizer) {

    if bottomViewHeight.constant > 0 && bottomViewBottomConstraint.constant < bottomViewHeight.constant{
      // BottomViewが表示されている場合

      switch recognizer.state {
      case .changed:

        guard
          let window = UIApplication.shared.windows.first,
          bottomView.frame.minY < UIScreen.main.bounds.height
          else { return }

        let origin = recognizer.location(in: window)
        let threthold = bounds.height - bottomView.intrinsicContentSize.height
        let length = origin.y - threthold

        if length > 0 {
          set(constraint: bottomViewBottomConstraint, value: length, animated: false)
          delegate?.didChangeHeight(height: feuilleKeyboardHeight(isIncludedTopViewHeight: isIncludedTopViewHeight) - length)
        }

      case .ended, .cancelled, .failed:

        if bottomViewBottomConstraint.constant > bottomView.intrinsicContentSize.height * 0.5 {
          #warning("scrollのvelocityも考慮してanimationする")
          set(constraint: bottomViewBottomConstraint, value: bottomView.intrinsicContentSize.height, animated: true)
          delegate?.didChangeHeight(height: middleView.frame.height)
        }
        else {
          set(constraint: bottomViewBottomConstraint, value: 0, animated: true)
          set(constraint: bottomViewHeight, value: bottomView.intrinsicContentSize.height, animated: true)
          delegate?.didChangeHeight(height: bottomView.intrinsicContentSize.height)
        }

      default:
        break
      }

    } else {

      // BottomViewが表示されていない or キーボードが表示されている

      guard
        case .changed = recognizer.state,
        let window = UIApplication.shared.windows.first,
        keyboardFrame.origin.y < UIScreen.main.bounds.height
        else { return }

      let origin = recognizer.location(in: window)
      var newFrame = keyboardFrame
      newFrame.origin.y = max(origin.y, UIScreen.main.bounds.height - keyboardFrame.height)

      keyboardFrame = newFrame

      let _keyboardHeight = UIScreen.main.bounds.height - keyboardFrame.minY

      set(constraint: keyboardHeight, value: _keyboardHeight, animated: false)
      delegate?.didChangeHeight(height: _keyboardHeight)

    }
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
