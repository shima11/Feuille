//
//  FeuilleContainerViewController.swift
//  Feuille
//
//  Created by jinsei_shima on 2019/02/21.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import Foundation

public class FeuilleView: UIView {
    
    // MARK: - Properties

    private let backdropView = BackDropView()
    private let contentView = ContentView()
  
    private let keyboardLayoutGuide: UILayoutGuide = .init()
    private var keyboardHeight: NSLayoutConstraint!
    
    // MARK: - Initializers

    public init() {
        super.init(frame: .zero)

        addSubview(backdropView)
        addSubview(contentView)
        
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
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: UInt(animationCurve << 16)),
            animations: {
                self.keyboardHeight.constant = -keyboardHeight!
                self.layoutIfNeeded()
        },
            completion: nil
        )
        
    }
}
