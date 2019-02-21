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

    public func dismiss() {

        set(constraint: bottomViewHeight, value: 0, animattion: true)
        topViewHeight.constant = 0
    }

    public func set(bottomView view: UIView) {

        set(constraint: bottomViewHeight, value: 200, animattion: true)

        bottomView.set(bodyView: view)
    }

    public func set(middleView view: UIView) {
        middleView.set(bodyView: view)
    }

    public func set(topView view: UIView) {

        topViewHeight.constant = 100

        topView.set(bodyView: view)
    }


    func set(constraint: NSLayoutConstraint, value: CGFloat, animattion: Bool){

        let animationDuration = animattion ? 0.25 : 0

        self.layoutIfNeeded()

        constraint.constant = value

        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            options: .overrideInheritedCurve,
            animations: {
                self.layoutIfNeeded()
        },
            completion: nil
        )
    }

    public init() {
        
        super.init(frame: .zero)

        do {
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

        do {

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

        do {

            middleView.translatesAutoresizingMaskIntoConstraints = false

            let a = middleView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
            a.priority = .defaultLow
            let b = middleView.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
            b.priority = .defaultLow

            NSLayoutConstraint.activate([
                middleView.rightAnchor.constraint(equalTo: rightAnchor),
                middleView.leftAnchor.constraint(equalTo: leftAnchor),
                middleView.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor),
                middleView.bottomAnchor.constraint(lessThanOrEqualTo: bottomView.topAnchor),
                a,
                b,
                middleView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor)
                ])
            
        }

        do {

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

        layoutIfNeeded()

    }


    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Functions

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

        self.layoutIfNeeded()

        self.keyboardHeight.constant = keyboardHeight!

        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: UInt(animationCurve << 16)),
            animations: {
                self.layoutIfNeeded()
        },
            completion: nil
        )
        
    }
}
