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
    let scrollAdapter = ScrollAdaptor()
    
    let customTextView = CustomInputView()
    let customTopView = CustomTopView()
    let photosView = PhotosView()
    let stanpView = StanpView()
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private let insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    var items: [Int] = (0...1).map { _ in Int.random(in: 0...100) }

    override func viewDidLoad() {
        
        super.viewDidLoad()

        view.addSubview(collectionView)
        view.addSubview(feuilleView)

        ui: do {
            
            collectionView.delegate = self
            collectionView.dataSource = self
            
            collectionView.alwaysBounceVertical = true
            collectionView.backgroundColor = .white
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: String(describing: UICollectionViewCell.self))
            collectionView.keyboardDismissMode = .interactive
            
            customTextView.backgroundColor = .lightGray
            customTextView.photoButton.addTarget(self, action: #selector(didTapPhotoButton), for: .touchUpInside)
            customTextView.previewButton.addTarget(self, action: #selector(didTapPreviewButton), for: .touchUpInside)
            customTextView.stanpButton.addTarget(self, action: #selector(didTapStanpButton), for: .touchUpInside)
            customTextView.addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
            customTextView.removeButton.addTarget(self, action: #selector(didTapRemoveButton), for: .touchUpInside)
            
            photosView.backgroundColor = .darkGray
            stanpView.backgroundColor = .orange
            
        }
        
        prepare: do {
            
            scrollAdapter.setScrollView(collectionView)

            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
            collectionView.addGestureRecognizer(gesture)
            
            feuilleView.delegate = self
            feuilleView.set(middleView: customTextView, animated: true)
            
        }
        
        layout: do {
            
            collectionView.easy.layout(Edges())
            feuilleView.easy.layout(Edges())
            
        }
        
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
        feuilleView.endEditing(true)
        feuilleView.dismiss(types: [.top, .bottom], animated: true)
    }
    
    @objc func didTapAddButton() {
        
        items.append(Int.random(in: 0...100))
        
        let indexPath = IndexPath.init(row: items.count - 1, section: 0)
        
        collectionView.insertItems(at: [indexPath])
//        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }

    @objc func didTapRemoveButton() {
        
        guard items.count > 1 else { return }

        items.removeLast()

        let indexPath = IndexPath.init(row: items.count - 1, section: 0)
        
        collectionView.deleteItems(at: [indexPath])
//        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
}

// MARK: - FeuilleViewDelegate

extension ViewController: FeuilleViewDelegate {
    
    func willShowKeybaord() { }
    
    func didShowKeyboard() { }
    
    func willHideKeyboard() { }
    
    func didHideKeyboard() { }
    
    func didChangeHeight(keyboardHeight: CGFloat, interactiveState: FeuilleView.InteractiveState) {
        
        print("height:", keyboardHeight)
        
        // 勝手にScrollしないように弾く（interactiveなKeyboardの移動中とintaractive transition中）
        guard
            case .completed = interactiveState,
            transitionCoordinator?.isInteractive != true
            else { return }
        
        scrollAdapter.scrollIfNeeded(keyboardHeight: keyboardHeight)
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
    public let addButton = UIButton(type: .system)
    public let removeButton = UIButton(type: .system)

    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }

    init() {
        super.init(frame: .zero)

        let stackView = UIStackView(
            arrangedSubviews: [
                photoButton,
                stanpButton,
                previewButton,
                textView,
                addButton,
                removeButton,
            ]
        )
        addSubview(stackView)
        
        backgroundColor = .white

        textView.backgroundColor = UIColor.groupTableViewBackground
        textView.isScrollEnabled = false
        textView.contentInset = .init(top: 8, left: 16, bottom: 8, right: 16)
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.layer.cornerRadius = textView.intrinsicContentSize.height / 2

        photoButton.setTitle("A", for: .normal)
        stanpButton.setTitle("B", for: .normal)
        previewButton.setTitle("C", for: .normal)
        addButton.setTitle("+", for: .normal)
        removeButton.setTitle("-", for: .normal)

        photoButton.setContentHuggingPriority(.required, for: .horizontal)
        previewButton.setContentHuggingPriority(.required, for: .horizontal)
        stanpButton.setContentHuggingPriority(.required, for: .horizontal)
        addButton.setContentHuggingPriority(.required, for: .horizontal)
        removeButton.setContentHuggingPriority(.required, for: .horizontal)

        stackView.easy.layout(
            Left(16),
            Right(16),
            Top(8),
            Bottom(8)
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

