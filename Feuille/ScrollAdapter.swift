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
    
    public func scrollIfNeeded(keyboardHeight: CGFloat) {
        
        guard let scrollView = scrollView else { return }
        
        defer {
            oldKeyboardHeight = keyboardHeight
        }
        
        let contentHeight: CGFloat
        #warning("insetの加算は必要？")
        if #available(iOS 11.0, *) {
            contentHeight = scrollView.contentSize.height + scrollView.safeAreaInsets.top
        } else {
            contentHeight = scrollView.contentSize.height + scrollView.layoutMargins.bottom
        }

        guard contentHeight + keyboardHeight > scrollView.bounds.height else {
            setContentInset(bottom: 0)
            scrollToTop(animated: true)
           return
        }

        let _offsetY = scrollView.contentOffset.y
        
        // Keyboardのheight分だけinsetを調整
        setContentInsetIfNeeded(keyboardHeight: keyboardHeight)
        
        if contentHeight < scrollView.bounds.height {
            // contentSizeがcollectionView.heightよりも小さい場合はKeyboard表示後BottomまでScroll
            scrollToBottom(animated: false, keyboardHeight: keyboardHeight)
        }
        else {
            // そうじゃないときはキーボード分だけ自動スクロール
            // insetを変更するとoffsetが変更する場合の対応
            let diffOffset = _offsetY - scrollView.contentOffset.y
            let offsetY = keyboardHeight - oldKeyboardHeight
            let newOffsetY = max((scrollView.contentOffset.y + offsetY + diffOffset), 0)
            
            scrollView.setContentOffset(
                .init(x: scrollView.contentOffset.x, y: newOffsetY),
                animated: false
            )
            // Option
            // Keybaord表示時にBottom付近までScrollされていたらKeyboardを閉じた後もBottomに合わせるようにする(Messenger)
//            if scrollView.isDragging &&
//                contentOffsetWhenBeginDragging >= diffOfContentHeightToCollectionHeight {
//                // DispatchQueue.main.asyncで囲んでいるのはScrollの慣性を止めるため
//                DispatchQueue.main.async {
//                    UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
//                        self.scrollToBottom(animated: false, keyboardHeight: keyboardHeight)
//                    }, completion: nil)
//                }
//            }
        }
    }
    
    
    private func setContentInsetIfNeeded(keyboardHeight: CGFloat) {
        
        guard
            let scrollView = scrollView,
            keyboardHeight > scrollView.bounds.height - scrollView.contentSize.height
            else {
                // keyboardが表示されてもスクロールする必要がない場合（十分なスペースがある場合）
                return
        }
        
        // Keyboardのheight分だけinsetを調整
        
        let _insetBottom: CGFloat
        if #available(iOS 11, *) {
            _insetBottom = max(keyboardHeight - scrollView.safeAreaInsets.bottom, 0)
        } else {
            _insetBottom = max(keyboardHeight, 0)
        }

        setContentInset(bottom: _insetBottom)
    }
    
    private func setContentInset(bottom: CGFloat) {
        
        guard let scrollView = scrollView else { return }
        
        scrollView.contentInset.bottom = bottom
        scrollView.scrollIndicatorInsets.bottom = bottom
    }
    
    public func scrollToTop(animated: Bool) {
        #warning("extensionでUICollectionViewとかで分けるか...それに伴ってジェネリクスで書くか")
        
        guard
            let scrollView = scrollView,
            !scrollView.scrollsToTop
            else { return }
        
        scrollView.setContentOffset(.zero, animated: animated)
    }
    
    public func scrollToBottom(animated: Bool, keyboardHeight: CGFloat) {
        #warning("extensionでUICollectionViewとかで分けるか...それに伴ってジェネリクスで書くか")
        
        #warning("たぶんここの計算がおかしい")
        
        guard let scrollView = scrollView else { return }
        
        let point = CGPoint.init(
            x: scrollView.contentOffset.x,
            y: scrollView.contentSize.height - scrollView.bounds.height + keyboardHeight
        )
        scrollView.setContentOffset(point, animated: animated)
    }
    
}
