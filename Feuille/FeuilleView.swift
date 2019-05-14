//
//  FeuilleContainerViewController.swift
//  Feuille
//
//  Created by jinsei_shima on 2019/02/21.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import Foundation

#warning("bottomView → keyboard animation without animation")
#warning("はみ出しの考慮（各Viewの合計が画面高さを超えたとき、上部のマージンとの兼ね合い）")
#warning("middleViewとsafeAreaのスペースの埋め方")
#warning("端末の回転への対応")
#warning("キーボードのインタラクションが始まるとScrollViewが固定される")
#warning("topviewが表示されたときも意図せずCollectionViewがスクロールする")

public protocol FeuilleViewDelegate: class {

  // ここのKeyboardはSystemKeyboardとCustomKeyboardの両方を含む（現状の実装ではSystemだけになっている）
  
  func willShowKeybaord()
  func didShowKeyboard()
  func willHideKeyboard()
  func didHideKeyboard()

  // height of keyboard or bottomview
  func didChangeHeight(keyboardHeight: CGFloat, interactiveState: FeuilleView.InteractiveState)
}

public class FeuilleView: TouchThroughView {

  public enum ItemType {
    case top, middle, bottom
  }

  public enum InteractiveState {
    case began, changed, completed
  }

  // MARK: - Properties

  public let topView = ContentView()
  public let middleView = ContentView()
  public let bottomView = ContentView()

  public weak var delegate: FeuilleViewDelegate?
  
  private let keyboardLayoutGuide: UILayoutGuide = .init()
  private var keyboardHeight: NSLayoutConstraint!

  private var topViewHeight: NSLayoutConstraint!
  private var bottomViewHeight: NSLayoutConstraint!

  private var bottomMiddleToKeyboardConstraint: NSLayoutConstraint!
  private var bottomMiddleToBottomConstraint: NSLayoutConstraint!
  private var bottomViewBottomConstraint: NSLayoutConstraint!

  private var isIncludedTopViewHeight: Bool = true

  private let panRecognizer = UIPanGestureRecognizer()

  private var interactiveState: InteractiveState = .completed

  private var keyboardFrame: CGRect
  private let defaultKeyboardFrame: CGRect
  private var oldFeuilleKeyboardHeight: CGFloat = 0

  
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

    addSubview(topView)
    addSubview(middleView)
    addSubview(bottomView)

    prepare: do {
      
      panRecognizer.delegate = self
      panRecognizer.addTarget(self, action: #selector(panGesture(_:)))
      UIApplication.shared.windows.first?.addGestureRecognizer(self.panRecognizer)
      
      startObserveKeyboard()
      
    }

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
        topView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 48),
        topView.rightAnchor.constraint(equalTo: rightAnchor),
        topView.leftAnchor.constraint(equalTo: leftAnchor),
        topView.bottomAnchor.constraint(equalTo: middleView.topAnchor),
        ])

    }

    middleView: do {

      middleView.translatesAutoresizingMaskIntoConstraints = false

      bottomMiddleToKeyboardConstraint = middleView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
      bottomMiddleToKeyboardConstraint.priority = .defaultLow
      bottomMiddleToBottomConstraint = middleView.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
      bottomMiddleToBottomConstraint.priority = .defaultLow

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
    UIApplication.shared.windows.first?.removeGestureRecognizer(self.panRecognizer)
  }

  // MARK: - Functions

  public func set(topView view: UIView, animated: Bool, isIncludedTopViewHeight: Bool) {

    self.isIncludedTopViewHeight = isIncludedTopViewHeight

    topView.set(bodyView: view)

    #warning("view.intrinsicContentSize.heightを設定しているのはbadかもしれない。intrinsicContentSizeが決まらない場合もありえそう。")
    
    setConstraint(topViewHeight, value: view.intrinsicContentSize.height, animated: animated)

  }

  public func set(middleView view: UIView, animated: Bool) {

    middleView.set(bodyView: view)
    middleView.backgroundColor = view.backgroundColor

    view.translatesAutoresizingMaskIntoConstraints = false

    if #available(iOS 11.0, *) {
      NSLayoutConstraint.activate([
        view.topAnchor.constraint(equalTo: middleView.topAnchor),
        view.rightAnchor.constraint(equalTo: middleView.rightAnchor),
        view.leftAnchor.constraint(equalTo: middleView.leftAnchor),
        view.bottomAnchor.constraint(equalTo: middleView.safeAreaLayoutGuide.bottomAnchor),
        ])
    } else {
      NSLayoutConstraint.activate([
        view.topAnchor.constraint(equalTo: middleView.topAnchor),
        view.rightAnchor.constraint(equalTo: middleView.rightAnchor),
        view.leftAnchor.constraint(equalTo: middleView.leftAnchor),
        view.bottomAnchor.constraint(equalTo: middleView.bottomAnchor),
        ])
    }

  }

  public func set(bottomView view: UIView, animated: Bool) {

    bottomView.set(bodyView: view)

    #warning("view.intrinsicContentSize.heightを設定しているのはbadかもしれない。intrinsicContentSizeが決まらない場合もありえそう。")

    if keyboardHeight.constant > 0 {
      // If there is a keyboard, no animation.
      dismissKeyboard(animated: false, force: true)
      setConstraint(bottomViewHeight, value: view.intrinsicContentSize.height, animated: false)
      setConstraint(bottomViewBottomConstraint, value: 0, animated: false)
    } else {
      setConstraint(bottomViewHeight, value: view.intrinsicContentSize.height, animated: animated)
      setConstraint(bottomViewBottomConstraint, value: 0, animated: animated)
    }

  }

  public func dismiss(types: [ItemType], animated: Bool) {

    if types.contains(.top) {
      setConstraint(topViewHeight, value: 0, animated: animated)
    }
    if types.contains(.bottom) {
      setConstraint(bottomViewBottomConstraint, value: bottomView.frame.height, animated: animated)
    }

  }

  public func dismissKeyboard(animated: Bool, force: Bool) {

    if animated {
      self.endEditing(force)
    } else {
      #warning("他のアニメーションが消える可能性がある")
      UIView.setAnimationsEnabled(false)
      self.endEditing(force)
      UIView.setAnimationsEnabled(true)
    }
  }

  private func didChangeHeightIfNeeded() {

    let height = feuilleKeyboardHeight(isIncludedTopViewHeight: isIncludedTopViewHeight)

    if height != oldFeuilleKeyboardHeight {
      delegate?.didChangeHeight(keyboardHeight: height, interactiveState: interactiveState)
    }

    oldFeuilleKeyboardHeight = height
  }

  public override func layoutSubviews() {

    super.layoutSubviews()

    didChangeHeightIfNeeded()
  }

  private func feuilleKeyboardHeight(isIncludedTopViewHeight: Bool) -> CGFloat {

    if isIncludedTopViewHeight {
      return bounds.height - topView.frame.minY
    }
    return bounds.height - middleView.frame.minY
  }

  private func setConstraint(
    _ constraint: NSLayoutConstraint,
    value: CGFloat,
    animated: Bool,
    animationDuration: TimeInterval = 0.25,
    animationOptions: UIView.AnimationOptions = [.beginFromCurrentState, .allowUserInteraction]
    ){

    if animated {

      constraint.constant = value

      UIView.animate(
        withDuration: animationDuration,
        delay: 0,
        options: animationOptions,
        animations: { self.layoutIfNeeded() },
        completion: nil
      )

    } else {
      constraint.constant = value
    }

  }

  @objc
  private func panGesture(_ recognizer: UIPanGestureRecognizer) {

    // ドラッグした場合の 1.Constraintsの更新と 2.Delegateメソッドの呼び出し
    
    switch recognizer.state {
    case .changed:
      self.interactiveState = .changed
    case .ended, .cancelled, .failed:
      self.interactiveState = .completed
    default:
      break
    }

    if bottomViewHeight.constant > 0 && bottomViewBottomConstraint.constant < bottomViewHeight.constant {
      
      // BottomViewが表示されている場合
      
      switch recognizer.state {
      case .changed:

        guard
          let window = UIApplication.shared.windows.first,
          bottomView.frame.minY < UIScreen.main.bounds.height
          else { return }

        let origin = recognizer.location(in: window)
        let threthold = bounds.height - bottomView.bounds.height
        let length = origin.y - threthold

        if length > 0 {
          setConstraint(bottomViewBottomConstraint, value: length, animated: false)
          delegate?.didChangeHeight(
            keyboardHeight: feuilleKeyboardHeight(isIncludedTopViewHeight: isIncludedTopViewHeight) - length,
            interactiveState: interactiveState
          )
        }

      case .ended, .cancelled, .failed:

        if bottomViewBottomConstraint.constant > bottomView.bounds.height * 0.5 {
          delegate?.willHideKeyboard()
          setConstraint(bottomViewBottomConstraint, value: bottomView.bounds.height, animated: true)
        }
        else {
          setConstraint(bottomViewBottomConstraint, value: 0, animated: true)
          setConstraint(bottomViewHeight, value: bottomView.bounds.height, animated: true)
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

      setConstraint(keyboardHeight, value: _keyboardHeight, animated: false)

    }
  }

}


// MARK: - Observing

extension FeuilleView {
  
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
      selector: #selector(keyboardWillHideNotification(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardDidHideNotification(_:)),
      name: UIResponder.keyboardDidHideNotification,
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
      selector: #selector(applicationDidFinishLaunching(_:)),
      name: UIApplication.didFinishLaunchingNotification,
      object: nil
    )
    
  }
  
  @objc
  private func applicationDidFinishLaunching(_ note: Notification) {
    // windowが生成されるタイミングで設定
    UIApplication.shared.windows.first?.addGestureRecognizer(self.panRecognizer)
  }
  
  @objc
  private func keyboardWillShowNotification(_ note: Notification) {
    
    // SystemKeyboardを開くときはbottomViewを非表示にする
    setConstraint(
      bottomViewBottomConstraint,
      value: bottomView.intrinsicContentSize.height,
      animated: false
    )

    delegate?.willShowKeybaord()
  }
  
  @objc
  private func keyboardDidShowNotification(_ note: Notification) {
    delegate?.didShowKeyboard()
  }
  
  @objc
  private func keyboardWillHideNotification(_ note: Notification) {
    delegate?.willHideKeyboard()
  }
  
  @objc
  private func keyboardDidHideNotification(_ note: Notification) {
    delegate?.didHideKeyboard()
  }
  
  @objc
  private func keyboardWillChangeFrame(_ note: Notification) {
    
    keyboardFrame = extractKeyboardFrame(note: note)
    
    // コメントアウトしているが、何かのためにこのタイミングで呼ぶ必要があったような気がする
//    if keyboardFrame.maxY <= bounds.height {
      // keyboardが開くとき
//      delegate?.willShowKeybaord()
      // bottomViewを非表示にする
//       setConstraint(
//        bottomViewBottomConstraint,
//        value: bottomView.intrinsicContentSize.height,
//        animated: false
//      )
//    } else {
      // keyboardが閉じるとき
//      delegate?.willHideKeyboard()
//    }
    
    // Keyboardの高さを変更（responderになって表示されるとき）
    
    setConstraint(
      keyboardHeight,
      value: UIScreen.main.bounds.height - keyboardFrame.minY,
      animated: true,
      animationDuration: extractKeyboardAnimationDuration(note: note),
      animationOptions: [extractKeyboardAnimationCurve(note: note), .beginFromCurrentState, .allowUserInteraction]
    )
    
  }
  
  // NotificationからFrame, duration, curveを抽出しているだけ
  
  private func extractKeyboardFrame(note: Notification) -> CGRect {
    
    let rectValue = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
    return rectValue?.cgRectValue ?? defaultKeyboardFrame
  }
  
  private func extractKeyboardAnimationDuration(note: Notification) -> Double {
    if let number = note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
      return number.doubleValue
    } else {
      return 0.25
    }
  }
  
  private func extractKeyboardAnimationCurve(note: Notification) -> UIView.AnimationOptions {
   
    let animationCurve: Int = {
      if let number = note.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
        return number.intValue
      }
      return UIView.AnimationCurve.easeInOut.rawValue
    }()
    
    return UIView.AnimationOptions(rawValue: UInt(animationCurve << 16))
  }

}


// MARK: - UIGestureRecognizerDelegate

extension FeuilleView: UIGestureRecognizerDelegate {

  // TODO: これ何してるんだっけ？
  
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
