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
    let customTopView = CustomTopView()

    let photosView = PhotosView()
    let stanpView = StanpView()

    var height: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()


        let button = UIButton(type: .system)
        button.frame = .init(x: 0, y: 0, width: 80, height: 44)
        button.center = view.center
        button.setTitle("Chat", for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.addTarget(self, action: #selector(didTapChatButton), for: .touchUpInside)

        view.addSubview(button)
        view.addSubview(feuilleView)

        feuilleView.frame = view.bounds
        feuilleView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        feuilleView.set(middleView: customTextView)

        customTextView.photoButton.addTarget(self, action: #selector(didTapPhotoButton), for: .touchUpInside)
        customTextView.previewButton.addTarget(self, action: #selector(didTapPreviewButton), for: .touchUpInside)
        customTextView.stanpButton.addTarget(self, action: #selector(didTapStanpButton), for: .touchUpInside)

        photosView.backgroundColor = .darkGray
        stanpView.backgroundColor = .orange

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(gesture)

    }

    @objc func didTapPhotoButton() {

        feuilleView.set(bottomView: photosView)

        _ = customTextView.resignFirstResponder()
    }

    @objc func didTapPreviewButton() {

        feuilleView.set(topView: customTopView)
    }

    @objc func didTapStanpButton() {

        feuilleView.set(bottomView: stanpView)

        _ = customTextView.resignFirstResponder()
    }

    @objc func didTapView() {

        _ = customTextView.resignFirstResponder()
        feuilleView.dismiss()
    }

    @objc func didTapChatButton() {

        _ = customTextView.becomeFirstResponder()

    }

}


class CustomTopView: UIView {

    init() {

        super.init(frame: .zero)

        backgroundColor = UIColor.darkGray.withAlphaComponent(0.4)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PhotosView: UIView {

    override var intrinsicContentSize: CGSize {
        return .init(width: UIView.noIntrinsicMetric, height: 400)
    }

    init() {

        super.init(frame: .zero)

        backgroundColor = .darkGray

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class StanpView: UIView {

    override var intrinsicContentSize: CGSize {
        return .init(width: UIView.noIntrinsicMetric, height: 200)
    }


    init() {

        super.init(frame: .zero)

        backgroundColor = .orange

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomInputView: UIView {

    public let photoButton = UIButton(type: .system)
    public let previewButton = UIButton(type: .system)
    public let stanpButton = UIButton(type: .system)
    public let textView = UITextView()

    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }


    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }

    init() {
        super.init(frame: .zero)

        addSubview(photoButton)
        addSubview(previewButton)
        addSubview(stanpButton)
        addSubview(textView)

        backgroundColor = .white

        textView.backgroundColor = UIColor.groupTableViewBackground
        textView.isScrollEnabled = false
        textView.contentInset = .init(top: 8, left: 16, bottom: 8, right: 16)
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        photoButton.setTitle("Photo", for: .normal)
        previewButton.setTitle("Preview", for: .normal)
        stanpButton.setTitle("Stanp", for: .normal)

        photoButton.setContentHuggingPriority(.required, for: .horizontal)
        previewButton.setContentHuggingPriority(.required, for: .horizontal)
        stanpButton.setContentHuggingPriority(.required, for: .horizontal)

        photoButton.easy.layout(
            Top(16),
            Left(16),
            Bottom(16)
        )

        previewButton.easy.layout(
            Left(16).to(photoButton, .right),
            CenterY().to(photoButton)
        )

        stanpButton.easy.layout(
            Left(16).to(previewButton, .right),
            CenterY().to(photoButton)
        )

        textView.easy.layout(
            Left(16).to(stanpButton, .right),
            CenterY().to(photoButton),
            Right(16)
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textView.layer.cornerRadius = textView.bounds.height / 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

