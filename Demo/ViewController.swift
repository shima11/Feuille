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

#warning("ScrollViewのスクロール対応をFeuilleとは分けて実装（キーボード表示時、Cellの追加時、ContentViewの下部時の対応）")
#warning("BottomViewをタップしてもBottomViewが閉じてしまう問題")

class ViewController: UIViewController {

    let feuilleView = FeuilleView()
    let scrollAdapter = ScrollAdaptor()
    
    let customTextView = CustomInputView()
    let customTopView = CustomTopView()

    let photosView = PhotosView()
    let stanpView = StanpView()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    var height: NSLayoutConstraint!

    private let insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    var items: [Int] = (0...1).map { _ in Int.random(in: 0...100) }

    override func viewDidLoad() {
        
        super.viewDidLoad()

        view.addSubview(collectionView)
        view.addSubview(feuilleView)

        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: String(describing: UICollectionViewCell.self))
        collectionView.keyboardDismissMode = .interactive

        feuilleView.delegate = self

        customTextView.photoButton.addTarget(self, action: #selector(didTapPhotoButton), for: .touchUpInside)
        customTextView.previewButton.addTarget(self, action: #selector(didTapPreviewButton), for: .touchUpInside)
        customTextView.stanpButton.addTarget(self, action: #selector(didTapStanpButton), for: .touchUpInside)
        customTextView.sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        
        photosView.backgroundColor = .darkGray
        stanpView.backgroundColor = .orange

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        view.addGestureRecognizer(gesture)

        collectionView.easy.layout(Edges())
        feuilleView.easy.layout(Edges())

        feuilleView.set(middleView: customTextView, animated: true)

        scrollAdapter.setScrollView(collectionView)
    }

    @objc func didTapPhotoButton() {
        feuilleView.set(bottomView: photosView, animated: true)
    }

    @objc func didTapPreviewButton() {
        feuilleView.set(topView: customTopView, animated: true, isIncludedTopViewHeight: true)
    }

    @objc func didTapStanpButton() {
        feuilleView.set(bottomView: stanpView, animated: true)
    }

    @objc func didTapView() {

        #warning("BottomViewをタップしたときも呼ばれてしまう")
        
        feuilleView.endEditing(true)
        feuilleView.dismiss(types: [.top, .bottom], animated: true)
    }
    
    @objc func didTapSendButton() {
        
        items.append(Int.random(in: 0...100))
        
        let indexPath = IndexPath.init(row: items.count - 1, section: 0)
        collectionView.insertItems(at: [indexPath])
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }

}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UICollectionViewCell.self), for: indexPath)

        let inputView = UIView()
        inputView.backgroundColor = UIColor.groupTableViewBackground
        inputView.layer.cornerRadius = 8
        inputView.clipsToBounds = true
        cell.addSubview(inputView)
        inputView.easy.layout(Edges(8))
        
        let label = UILabel()
        label.text = "\(items[indexPath.row])"
        inputView.addSubview(label)
        label.easy.layout(Center())
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return insets
    }
}

// MARK: - FeuilleViewDelegate

extension ViewController: FeuilleViewDelegate {

    func willShowKeybaord() {

    }

    func didShowKeyboard() {

    }

    func willHideKeyboard() {

    }

    func didHideKeyboard() {

    }

    func didChangeHeight(keyboardHeight: CGFloat, interactiveState: FeuilleView.InteractiveState) {

        print("height:", keyboardHeight)

        let safeAreaBottomInset: CGFloat
        if #available(iOS 11.0, *) {
            safeAreaBottomInset  = view.safeAreaInsets.bottom
        } else {
            safeAreaBottomInset = bottomLayoutGuide.length
        }

        collectionView.contentInset = .init(
            top: collectionView.contentInset.top,
            left: collectionView.contentInset.left,
            bottom: insets.bottom + keyboardHeight - safeAreaBottomInset,
            right: collectionView.contentInset.right
        )

        collectionView.scrollIndicatorInsets = .init(
            top: collectionView.scrollIndicatorInsets.top,
            left: collectionView.scrollIndicatorInsets.left,
            bottom: insets.bottom + keyboardHeight - safeAreaBottomInset,
            right: collectionView.scrollIndicatorInsets.right
        )
        
        // 勝手にScrollしないように弾く（interactiveなKeyboardの移動中とintaractive transition中）
        guard
            case .completed = interactiveState,
            transitionCoordinator?.isInteractive != true
            else { return }

        #warning("キーボードの上昇分だけCollectionViewをスライドさせる")
        scrollAdapter.scrollIfNeeded(keyboardHeight: keyboardHeight)

    }
    
}

// MARK: - CustomView

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

    public let photoButton = UIButton(type: .system)
    public let previewButton = UIButton(type: .system)
    public let stanpButton = UIButton(type: .system)
    public let textView = UITextView()
    public let sendButton = UIButton(type: .system)

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
        addSubview(sendButton)

        backgroundColor = .white

        textView.backgroundColor = UIColor.groupTableViewBackground
        textView.isScrollEnabled = false
        textView.contentInset = .init(top: 8, left: 16, bottom: 8, right: 16)
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.layer.cornerRadius = textView.intrinsicContentSize.height / 2

        photoButton.setTitle("Photo", for: .normal)
        previewButton.setTitle("Top", for: .normal)
        stanpButton.setTitle("Stamp", for: .normal)
        sendButton.setTitle("Send", for: .normal)

        photoButton.setContentHuggingPriority(.required, for: .horizontal)
        previewButton.setContentHuggingPriority(.required, for: .horizontal)
        stanpButton.setContentHuggingPriority(.required, for: .horizontal)
        sendButton.setContentHuggingPriority(.required, for: .horizontal)

        photoButton.easy.layout(
            Left(16),
            Top(>=8),
            Bottom(8)
        )

        previewButton.easy.layout(
            Left(16).to(photoButton, .right),
            Top(>=8),
            Bottom(8)
        )

        stanpButton.easy.layout(
            Left(16).to(previewButton, .right),
            Top(>=8),
            Bottom(8)
        )

        textView.easy.layout(
            Left(16).to(stanpButton, .right),
            Top(8),
            Bottom(8)
        )
        
        sendButton.easy.layout(
            Left(16).to(textView, .right),
            Right(16),
            Top(>=8),
            Bottom(8)
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

