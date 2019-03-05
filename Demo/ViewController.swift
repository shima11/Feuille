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

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    var height: NSLayoutConstraint!

    private let insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        view.addSubview(feuilleView)

        collectionView.contentSize = .init(width: UIScreen.main.bounds.width, height: 1000)

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.backgroundColor = .white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.keyboardDismissMode = .interactive

        feuilleView.delegate = self
        feuilleView.set(middleView: customTextView, animated: true)

        customTextView.photoButton.addTarget(self, action: #selector(didTapPhotoButton), for: .touchUpInside)
        customTextView.previewButton.addTarget(self, action: #selector(didTapPreviewButton), for: .touchUpInside)
        customTextView.stanpButton.addTarget(self, action: #selector(didTapStanpButton), for: .touchUpInside)

        photosView.backgroundColor = .darkGray
        stanpView.backgroundColor = .orange

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(gesture)

        feuilleView.easy.layout(Edges())

        if #available(iOS 11.0, *) {
            collectionView.easy.layout(
                Top(),
                Left(),
                Bottom().to(view.safeAreaLayoutGuide, .bottom),
                Right()
            )
        } else {
            collectionView.easy.layout(
                Top(),
                Left(),
                Bottom().to(bottomLayoutGuide, .top),
                Right()
            )
        }

    }

    @objc func didTapPhotoButton() {

        feuilleView.set(bottomView: photosView, animated: true)

        _ = customTextView.resignFirstResponder()
    }

    @objc func didTapPreviewButton() {

        feuilleView.set(topView: customTopView, animated: true, isIncludedTopViewHeight: true)
    }

    @objc func didTapStanpButton() {

        feuilleView.set(bottomView: stanpView, animated: true)

        _ = customTextView.resignFirstResponder()
    }

    @objc func didTapView() {

        _ = customTextView.endEditing(true)
        feuilleView.dismiss(type: .top, animated: true)
        feuilleView.dismiss(type: .bottom, animated: true)
    }

}

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        let inputView = UIView()
        inputView.backgroundColor = UIColor.groupTableViewBackground
        inputView.layer.cornerRadius = 8
        inputView.clipsToBounds = true
        cell.addSubview(inputView)
        inputView.easy.layout(Edges(8))

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }

}

extension ViewController: UICollectionViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }

}

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
}


extension ViewController: FeuilleViewDelegate {

    func didChangeHeight(height: CGFloat) {

//        print("height:", height)

        collectionView.contentInset = .init(
            top: collectionView.contentInset.top,
            left: collectionView.contentInset.left,
            bottom: insets.bottom + height,
            right: collectionView.contentInset.right
        )

        collectionView.scrollIndicatorInsets = .init(
            top: collectionView.scrollIndicatorInsets.top,
            left: collectionView.scrollIndicatorInsets.left,
            bottom: insets.bottom + height,
            right: collectionView.scrollIndicatorInsets.right
        )

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

