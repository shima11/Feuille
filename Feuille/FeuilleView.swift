//
//  FeuilleContainerViewController.swift
//  Feuille
//
//  Created by jinsei_shima on 2019/02/21.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import Foundation

public class FeuilleView: TouchThroughView {
    
    // MARK: - Properties

    public let topView = ContentView()
    public let middleView = ContentView()
    public let bottomView = ContentView()

    private let keyboardLayoutGuide: UILayoutGuide = .init()
    private var keyboardHeight: NSLayoutConstraint!

    private var bottomViewHeight: NSLayoutConstraint!

    private var topViewHeight: NSLayoutConstraint!

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

            #warning("Think about a top constraint")

            NSLayoutConstraint.activate([
                topView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 24),
                topView.rightAnchor.constraint(equalTo: rightAnchor),
                topView.leftAnchor.constraint(equalTo: leftAnchor),
                topView.bottomAnchor.constraint(equalTo: middleView.topAnchor),
                ])

        }

        middleView: do {

            middleView.translatesAutoresizingMaskIntoConstraints = false

            let constraint1 = middleView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
            constraint1.priority = .defaultLow
            let constraint2 = middleView.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
            constraint2.priority = .defaultLow

            NSLayoutConstraint.activate([
                middleView.rightAnchor.constraint(equalTo: rightAnchor),
                middleView.leftAnchor.constraint(equalTo: leftAnchor),
                middleView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor),
                middleView.bottomAnchor.constraint(lessThanOrEqualTo: bottomView.topAnchor),
                constraint1,
                constraint2,
                middleView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor)
                ])
            
        }

        bottomView: do {

            bottomView.translatesAutoresizingMaskIntoConstraints = false

            bottomViewHeight = bottomView.heightAnchor.constraint(equalToConstant: 0)
            bottomViewHeight.isActive = true

            NSLayoutConstraint.activate([
                bottomView.rightAnchor.constraint(equalTo: rightAnchor),
                bottomView.leftAnchor.constraint(equalTo: leftAnchor),
                bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
                ])

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

    public func set(bottomView view: UIView) {

        topViewHeight.constant = 0

        #warning("Think about a way to decide the bottomViewHeight.")

        set(constraint: bottomViewHeight, value: 200, animated: true)

        bottomView.set(bodyView: view)
    }

    public func set(middleView view: UIView) {

        topViewHeight.constant = 0

        middleView.set(bodyView: view)
    }

    public func set(topView view: UIView) {

        #warning("Think about a way to decide the topViewHeight.")

        topViewHeight.constant = 100

        topView.set(bodyView: view)
    }

    public func dismiss() {

        topViewHeight.constant = 0

        set(constraint: bottomViewHeight, value: 0, animated: true)
    }


    private func set(
        constraint: NSLayoutConstraint,
        value: CGFloat,
        animated: Bool,
        animationDuration: TimeInterval = 0.25,
        animationOptions: UIView.AnimationOptions = .overrideInheritedCurve
        ){


        if animated {

            self.layoutIfNeeded()

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

        set(
            constraint: self.keyboardHeight,
            value: keyboardHeight!,
            animated: true,
            animationDuration: animationDuration,
            animationOptions: UIView.AnimationOptions(rawValue: UInt(animationCurve << 16))
        )

    }
}
