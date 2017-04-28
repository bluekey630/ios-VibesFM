//
//  UIImage+DropShadow.swift
//  Radio
//
//  Created by Admin on 11/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit

extension UIImageView {

    // APPLY DROP SHADOW
    func applyShadow() {
		let layer           = self.layer
		layer.shadowColor   = UIColor.blackColor().CGColor
		layer.shadowOffset  = CGSize(width: 0, height: 0)
		layer.shadowOpacity = 0.6
        layer.shadowRadius  = self.bounds.height / 2 + 2
    }

}
