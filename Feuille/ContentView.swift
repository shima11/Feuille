//
//  ContentView.swift
//  Feuille
//
//  Created by jinsei_shima on 2019/02/21.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import Foundation

public class ContentView: UIView {

    private weak var bodyView: UIView? = nil

    public func set(bodyView: UIView) {

        self.bodyView?.removeFromSuperview()
        addSubview(bodyView)
        self.bodyView = bodyView

        bodyView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bodyView.topAnchor.constraint(equalTo: topAnchor),
            bodyView.leftAnchor.constraint(equalTo: leftAnchor),
            bodyView.rightAnchor.constraint(equalTo: rightAnchor),
            bodyView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])

    }


}
