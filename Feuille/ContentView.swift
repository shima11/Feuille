//
//  ContentView.swift
//  Feuille
//
//  Created by jinsei_shima on 2019/02/21.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import Foundation

public class ContentView: UIView {

    public override var intrinsicContentSize: CGSize {
        return bodyView?.intrinsicContentSize ?? .init(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }

    private weak var bodyView: UIView? = nil

    func set(bodyView: UIView) {

        self.bodyView?.removeFromSuperview()
        addSubview(bodyView)
        self.bodyView = bodyView

        bodyView.translatesAutoresizingMaskIntoConstraints = false

        // auto sizing mask と nslayoutconstraint の違い

        NSLayoutConstraint.activate([
            bodyView.topAnchor.constraint(equalTo: topAnchor),
            bodyView.leftAnchor.constraint(equalTo: leftAnchor),
            bodyView.rightAnchor.constraint(equalTo: rightAnchor),
            bodyView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])

        layoutIfNeeded()

    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        print("content view frame", frame)
    }

}
