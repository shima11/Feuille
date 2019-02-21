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

//    public let topView = ContentView()
    public let middleView = ContentView()
    public let bottomView = ContentView() // <-

    private let bottomLayoutGuide: UILayoutGuide = .init()
    private var keyboardHeight: NSLayoutConstraint!
    private var bottomViewHeight: NSLayoutConstraint!

    // MARK: - Initializers

    public init() {
        super.init(frame: .zero)

        do {
            addLayoutGuide(bottomLayoutGuide)
            
            let height = bottomLayoutGuide.heightAnchor.constraint(equalToConstant: 0)
//            height.priority = .defaultHigh
            self.keyboardHeight = height

            NSLayoutConstraint.activate([
                height,
                bottomLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor),
                bottomLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor),
                bottomLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
                ])
            
        }

//        addSubview(topView)
        addSubview(middleView)
        addSubview(bottomView)

//        do {
//
//            topView.translatesAutoresizingMaskIntoConstraints = false
//
//            NSLayoutConstraint.activate([
//                topView.rightAnchor.constraint(equalTo: rightAnchor),
//                topView.leftAnchor.constraint(equalTo: leftAnchor),
//                topView.bottomAnchor.constraint(equalTo: middleView.topAnchor),
//                ])
//
//        }

        do {

            middleView.translatesAutoresizingMaskIntoConstraints = false

            let a = middleView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
            a.priority = .defaultLow
            let b = middleView.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
            b.priority = .defaultLow

            NSLayoutConstraint.activate([
                middleView.rightAnchor.constraint(equalTo: rightAnchor),
                middleView.leftAnchor.constraint(equalTo: leftAnchor),
                middleView.bottomAnchor.constraint(lessThanOrEqualTo: bottomLayoutGuide.topAnchor),
                middleView.bottomAnchor.constraint(lessThanOrEqualTo: bottomView.topAnchor),
                a,
                b
                ])
            
        }

        do {

            bottomView.translatesAutoresizingMaskIntoConstraints = false
            bottomView.heightAnchor.constraint(equalToConstant: 200).isActive = true

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
