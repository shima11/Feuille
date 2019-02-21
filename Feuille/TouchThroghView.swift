//
//  TouchThroghView.swift
//  Feuille
//
//  Created by jinsei_shima on 2019/02/21.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import Foundation

public class TouchThroughView : UIView {

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        let view = super.hitTest(point, with: event)

        if view == self || view?.isDescendant(of: self) == false {

            return nil
        }
        return view
    }
}
