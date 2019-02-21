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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(feuilleView)
        feuilleView.frame = view.bounds
        

    }


}

