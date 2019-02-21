//
//  FeuilleContainerViewController.swift
//  Feuille
//
//  Created by jinsei_shima on 2019/02/21.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import Foundation

public class FeuilleView: UIView {

    private let backdropView = BackDropView()
    private let contentView = ContentView()
  
    private let keyboardLayoutGuide: UILayoutGuide = .init()

    public init() {
        super.init(frame: .zero)

        addSubview(backdropView)
        addSubview(contentView)

    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
