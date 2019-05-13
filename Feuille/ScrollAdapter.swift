//
//  ScrollAdapter.swift
//  Feuille
//
//  Created by jinsei_shima on 2019/05/13.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import Foundation

public class ScrollAdaptor {
    
    private var scrollView: UIScrollView?
    
    private var oldKeyboardHeight: CGFloat = 0
    private var contentOffsetWhenBeginDragging: CGFloat = 0 // スクロール時のOffsetを保持してMessengerみたいな挙動を確認
    
    
    public init() {
        
    }
    
    public func setScrollView(_ view: UIScrollView) {
        scrollView = view
    }
    
    public func set(keyboardHeight: CGFloat) {
        
        guard let scrollView = scrollView else { return }
        
        defer {
            oldKeyboardHeight = keyboardHeight
        }
        
        let contentHeight: CGFloat
        if #available(iOS 11.0, *) {
            contentHeight = scrollView.contentSize.height + scrollView.safeAreaInsets.top
        } else {
            contentHeight = scrollView.contentSize.height + scrollView.layoutMargins.bottom
        }
        
        let diffOfContentHeightToCollectionHeight = contentHeight - scrollView.bounds.height
        
        if diffOfContentHeightToCollectionHeight < 0 {
            // contentSizeがbounds.heightよりも小さい場合 → Keybaord表示後BottomまでScrollしているので、元に戻す
            scrollView.contentInset.bottom = 0
            scrollView.scrollIndicatorInsets.bottom = 0
            scrollToTop(animated: true)
        }
        
        // Keyboardを開いてもContentが重ならないはScrollする必要がないので弾く
        guard diffOfContentHeightToCollectionHeight + keyboardHeight > 0 else { return }
        
        let _offset = scrollView.contentOffset.y
        
        // Keyboardのheight分だけinsetを調整
        setContentInsetIfNeeded(keyboardHeight: keyboardHeight)
        
        // contentSizeがcollectionView.heightよりも小さい場合はKeyboard表示後BottomまでScroll
        if diffOfContentHeightToCollectionHeight < 0 {
            scrollToBottom(animated: false)
        }
        else {
            // insetを変更するとoffsetが変更する場合の対応
            let diffOffset = _offset - scrollView.contentOffset.y
            
            let offsetY = keyboardHeight - oldKeyboardHeight
            let newOffsetY = max((scrollView.contentOffset.y + offsetY + diffOffset), 0)
            
            scrollView.setContentOffset(
                .init(x: scrollView.contentOffset.x, y: newOffsetY),
                animated: false
            )
            // Keybaord表示時にBottom付近までScrollされていたらKeyboardを閉じた後もBottomに合わせるようにする(Messenger)
            if scrollView.isDragging &&
                contentOffsetWhenBeginDragging >= diffOfContentHeightToCollectionHeight {
                // DispatchQueue.main.asyncで囲んでいるのはScrollの慣性を止めるため
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                        self.scrollToBottom(animated: false)
                    }, completion: nil)
                }
            }
        }
    }
    
    
    private func setContentInsetIfNeeded(keyboardHeight: CGFloat) {
        
        guard
            let scrollView = scrollView,
            keyboardHeight > scrollView.bounds.height - scrollView.contentSize.height
            else { return }
        
        // Keyboardのheight分だけinsetを調整
        
        let margin: CGFloat = 4.0
        
        let _insetBottom: CGFloat
        
        if #available(iOS 11, *) {
            _insetBottom = max(keyboardHeight - scrollView.safeAreaInsets.bottom, 0) + margin
        } else {
            _insetBottom = max(keyboardHeight, 0) + margin
        }
        
        scrollView.contentInset.bottom = _insetBottom
        scrollView.scrollIndicatorInsets.bottom = _insetBottom
        
    }
    
    public func scrollToTop(animated: Bool) {
        #warning("extensionでUICollectionViewとかで分けるか...それに伴ってジェネリクスで書くか")
        
        guard
            let scrollView = scrollView,
            !scrollView.scrollsToTop
            else { return }
        
        scrollView.setContentOffset(.zero, animated: animated)
    }
    
    public func scrollToBottom(animated: Bool) {
        #warning("extensionでUICollectionViewとかで分けるか...それに伴ってジェネリクスで書くか")
        
        guard let scrollView = scrollView else { return }
        
        let point = CGPoint.init(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y - scrollView.bounds.height)
        scrollView.setContentOffset(point, animated: animated)
    }
    
}
