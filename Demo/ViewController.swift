//
//  ViewController.swift
//  Demo
//
//  Created by jinsei_shima on 2019/02/21.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import UIKit
import Feuille

class ViewController: UIViewController {

    let feuilleView = FeuilleView()

    let textView = UITextView()

    var height: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()


        let button = UIButton(type: .system)
        button.setTitle("button", for: .normal)
        button.titleLabel?.textColor = .darkText
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.frame = .init(x: 0, y: 0, width: 120, height: 60)
        button.center = view.center

        view.addSubview(button)

        view.addSubview(feuilleView)

        feuilleView.frame = view.bounds
        feuilleView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        textView.backgroundColor = .red
        textView.isScrollEnabled = false
    }


    @objc func didTapButton() {

        feuilleView.contentView.set(bodyView: textView)
        textView.becomeFirstResponder()

    }


}

