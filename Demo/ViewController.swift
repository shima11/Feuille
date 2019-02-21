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

    let customTextView = CustomInputView()
    let customBottomView = CustomBottomView()

    var height: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()


        let button = UIButton(type: .system)
        button.frame = .init(x: 0, y: 0, width: 80, height: 44)
        button.center = view.center
        button.setTitle("Chat", for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)

        view.addSubview(button)
        view.addSubview(feuilleView)

        feuilleView.frame = view.bounds
        feuilleView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        feuilleView.set(middleView: customTextView)

        customTextView.set(tapHandler: { [weak self] in

            guard let self = self else { return }

            self.feuilleView.set(bottomView: self.customBottomView)

            _ = self.customTextView.resignFirstResponder()
        })

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(gesture)

    }

    @objc func didTapView() {
        _ = customTextView.resignFirstResponder()
        feuilleView.dismiss()
    }

    @objc func didTapButton() {

        _ = customTextView.becomeFirstResponder()

    }

}


class CustomBottomView: UIView {

    init() {

        super.init(frame: .zero)

        backgroundColor = .darkGray

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        backgroundColor = .white

        textView.backgroundColor = UIColor.groupTableViewBackground
        textView.isScrollEnabled = false
        textView.contentInset = .init(top: 8, left: 16, bottom: 8, right: 16)
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        button.setTitle("Photos", for: .normal)

        button.easy.layout(
            Top(16),
            Left(16),
            Bottom(16)
        )

        textView.easy.layout(
            Left(16).to(button, .right),
            CenterY().to(button),
            Right(16)
        )

        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)

    }

    @objc func didTap() {
        handler()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textView.layer.cornerRadius = textView.bounds.height / 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

