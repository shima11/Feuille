//
//  ViewController.swift
//  Demo
//
//  Created by jinsei_shima on 2019/02/21.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import UIKit

import EasyPeasy

import Feuille


class ViewController: UIViewController {

    let feuilleView = FeuilleView()

    let textView = CustomInputView()
    let bottomView = UIView()

    var height: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()


        let button = UIButton(type: .system)
        button.setTitle("button", for: .normal)
        button.titleLabel?.textColor = .darkText
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.frame = .init(x: 0, y: 0, width: 120, height: 60)
        button.center = view.center

        view.addSubview(button)

        view.addSubview(feuilleView)

        feuilleView.frame = view.bounds
        feuilleView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        bottomView.backgroundColor = .blue

        textView.set(tapHandler: { [weak self] in

            guard let self = self else { return }

            self.feuilleView.bottomView.set(bodyView: self.bottomView)

            _ = self.textView.resignFirstResponder()
        })
    }


    @objc func didTapButton() {

        feuilleView.middleView.set(bodyView: textView)
        _ = textView.becomeFirstResponder()

    }


}

class CustomInputView: UIView {

    public let textView = UITextView()
    public let button = UIButton(type: .system)

    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }


    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }

    var handler: (() -> Void) = {}

    func set(tapHandler: @escaping () -> Void) {
        handler = tapHandler
    }


    init() {
        super.init(frame: .zero)

        addSubview(textView)
        addSubview(button)

        textView.isScrollEnabled = false

        button.setTitle("Hoge", for: .normal)

        button.setContentHuggingPriority(.required, for: .horizontal)
        
        button.easy.layout(
            Top(16),
            Left(16),
            Bottom(16)
        )

        textView.easy.layout(
            Left().to(button, .right),
            CenterY().to(button),
            Right(16)
        )

        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)

    }

    @objc func didTap() {
        handler()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

