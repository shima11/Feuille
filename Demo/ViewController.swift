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

    let chatButton = UIButton(type: .system)

    let scrollView = UIScrollView()

    var height: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)
        view.addSubview(feuilleView)

        scrollView.addSubview(chatButton)

        scrollView.contentSize = .init(width: UIScreen.main.bounds.width, height: 1000)
        scrollView.keyboardDismissMode = .interactive

        chatButton.frame = .init(x: 0, y: 0, width: 80, height: 44)
        chatButton.setTitle("Chat", for: .normal)
        chatButton.setContentHuggingPriority(.required, for: .horizontal)
        chatButton.addTarget(self, action: #selector(didTapChatButton), for: .touchUpInside)

        feuilleView.set(middleView: customTextView, animated: true)
        feuilleView.delegate = self

        customTextView.photoButton.addTarget(self, action: #selector(didTapPhotoButton), for: .touchUpInside)
        customTextView.previewButton.addTarget(self, action: #selector(didTapPreviewButton), for: .touchUpInside)
        customTextView.stanpButton.addTarget(self, action: #selector(didTapStanpButton), for: .touchUpInside)

        photosView.backgroundColor = .darkGray
        stanpView.backgroundColor = .orange

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(gesture)


        feuilleView.easy.layout(Edges())

        scrollView.easy.layout(Edges())

        chatButton.easy.layout(
            Center()
        )

    }

    @objc func didTapPhotoButton() {

        feuilleView.set(bottomView: photosView, animated: true)

        _ = customTextView.resignFirstResponder()
    }

    @objc func didTapPreviewButton() {

        feuilleView.set(topView: customTopView, animated: true)
    }

    @objc func didTapStanpButton() {

        feuilleView.set(bottomView: stanpView, animated: true)

        _ = customTextView.resignFirstResponder()
    }

    @objc func didTapView() {

        _ = customTextView.endEditing(true)
        feuilleView.dismiss(types: [.top, .bottom], animated: true)
    }

    @objc func didTapChatButton() {

        _ = customTextView.becomeFirstResponder()

    }

}

extension ViewController: FeuilleViewDelegate {

    func didChangeHeight(height: CGFloat) {

        print("height:", height)

        // LINE形式
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.height {
            scrollView.setContentOffset(.init(x: scrollView.contentOffset.x, y: height), animated: true)
        }
    }

}


class CustomTopView: UIView {

    override var intrinsicContentSize: CGSize {
        return .init(width: UIView.noIntrinsicMetric, height: 200)
    }

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

    override var intrinsicContentSize: CGSize {
        return .init(width: UIView.noIntrinsicMetric, height: 44)
    }

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
            Left(16),
            CenterY()
        )

        previewButton.easy.layout(
            Left(16).to(photoButton, .right),
            CenterY()
        )

        stanpButton.easy.layout(
            Left(16).to(previewButton, .right),
            CenterY()
        )

        textView.easy.layout(
            Left(16).to(stanpButton, .right),
            Right(16),
            CenterY()
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

