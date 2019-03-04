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

  private var topViewHeight: NSLayoutConstraint!
  private var middleViewHeight: NSLayoutConstraint!
  private var bottomViewHeight: NSLayoutConstraint!

  private let keyboardLayoutGuide: UILayoutGuide = .init()
  private var keyboardHeight: NSLayoutConstraint!

  private var bottomMiddleToKeyboardConstraint: NSLayoutConstraint!
  private var bottomMiddleToBottomConstraint: NSLayoutConstraint!

  public weak var delegate: FeuilleViewDelegate?

  // MARK: - Initializers

  public init() {

    super.init(frame: .zero)

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

  public func set(topView view: UIView, animated: Bool) {

    #warning("topViewをdelegateで返すheightに含むかのパラメータ検討")

    topView.set(bodyView: view)

    set(constraint: topViewHeight, value: view.intrinsicContentSize.height, animated: animated)

    let height = topView.intrinsicContentSize.height + middleView.intrinsicContentSize.height + bottomView.intrinsicContentSize.height
    delegate?.didChangeHeight(height: height)

  }

  public func set(middleView view: UIView, animated: Bool) {

    middleView.set(bodyView: view)
    set(constraint: middleViewHeight, value: view.intrinsicContentSize.height, animated: animated)

    let height = topView.intrinsicContentSize.height + middleView.intrinsicContentSize.height + bottomView.intrinsicContentSize.height
    delegate?.didChangeHeight(height: height)

  }

  public func set(bottomView view: UIView, animated: Bool) {

    bottomView.set(bodyView: view)
    set(constraint: bottomViewHeight, value: view.intrinsicContentSize.height, animated: animated)

    let height = topView.intrinsicContentSize.height + middleView.intrinsicContentSize.height + bottomView.intrinsicContentSize.height
    delegate?.didChangeHeight(height: height)

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

  }

  @objc
  private func keyboardWillChangeFrame(_ note: Notification) {

    #warning("scroll中のkeyobard dismissの対応、これだけだとドラッグ中のキーボードの高さの変化に追従できない")

    var keyboardHeight: CGFloat? {
      guard let v = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
        return nil
      }
      let screenHeight = UIScreen.main.bounds.height
      return screenHeight - v.cgRectValue.minY
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

    if let height = keyboardHeight, height > 0 {
        // keyboardが開くときはbottomViewを閉じる
      bottomViewHeight.constant = 0
    }

    set(
      constraint: self.keyboardHeight,
      value: keyboardHeight!,
      animated: true,
      animationDuration: animationDuration,
      animationOptions: UIView.AnimationOptions(rawValue: UInt(animationCurve << 16))
    )

  }

}
